---
name: diagnose-cross-node-link
description: Triage cross-host link issues — when a service on host A is reverse-proxied or dialed from host B and it intermittently stalls, returns partial responses, or breaks on large payloads. Already-mapped patterns we hit in this infra (RU↔OCI selective drop, MTU blackholes, NSG firewall denials, container-network DNAT misses).
---

# Diagnose a cross-node link

Symptoms that should send you here:

- Small HTTP responses (HEAD, redirects, headers) succeed; large bodies stall mid-stream.
- Browser shows a blank SPA but headers say `200 OK`.
- traefik logs `Error while handling TCP connection ... readfrom tcp ... use of closed network connection`.
- `curl --max-time` to a backend through the proxy returns truncated bytes after a fast TTFB.

The 98 KB stall is the canonical "RU↔OCI peering is broken" signature.

## Step 1 — isolate by transfer size

```bash
# Small response — should be instant
curl -sS --max-time 5 -o /dev/null -w "HTTP %{http_code} ttfb=%{time_starttransfer}s\n" \
    -I https://<endpoint>/

# Large response — the actual symptom
curl -sS --max-time 20 -o /dev/null -w "size=%{size_download}B total=%{time_total}s\n" \
    https://<endpoint>/<large-asset>
```

If small=OK and large=stall → packet loss or PMTUD black-hole on the path.
Continue.

## Step 2 — bypass the proxy

```bash
ansible -i hosts.yml <proxy-host> -m shell -b \
    -a 'docker exec proxy wget -q -O /dev/null --timeout=15 http://<backend-host>:<port>/<asset>'
```

If the same backend asset stalls when fetched directly from the proxy host
(no traefik in the middle), the issue is on the proxy↔backend network leg,
not in traefik or the SPA.

## Step 3 — capture retransmits on the backend host

```bash
ansible -i hosts.yml <backend-host> -m shell -b -a \
    'timeout 15 tcpdump -i <iface> -n -c 80 "tcp and host <proxy-host-ip> and port <port>"'
```

Trigger the failing transfer from a client *while* the capture is running.
Pattern to look for:

```
IP 10.0.0.204.80 > 109.172.90.19.47634: Flags [.], seq 0:1448, ack 1, ..., length 1448
IP 10.0.0.204.80 > 109.172.90.19.47634: Flags [.], seq 0:1448, ack 1, ..., length 1448
IP 10.0.0.204.80 > 109.172.90.19.47634: Flags [.], seq 0:1448, ack 1, ..., length 1448
```

Same `seq 0:1448` repeated with growing intervals (4 s → 9 s → 18 s) and
tiny total packet count (3 in 15 s) ⇒ sender keeps shipping, no ACKs come
back. **In our infra: RU(node2)↔OCI(sweden) link does this.** Treat as
unfixable on our side — move the service to a non-OCI / non-RU host.

## Step 4 — check MTU on both ends

```bash
ansible -i hosts.yml <host> -m shell -a 'ip link show <iface> | head -2'
```

OCI VMs default to MTU 9000 (jumbo). Doesn't usually matter for outbound to
MTU-1500 paths because TCP MSS clamps from the peer's SYN, but worth
checking. Transient drop:
```bash
ansible -i hosts.yml <host> -m shell -b -a 'ip link set dev <iface> mtu 1500'
```
Persist via netplan if it actually helps.

If lowering MTU does NOT change the 98 KB stall → MTU is innocent. Restore
default and look elsewhere.

## Step 5 — check cloud-provider firewall

If the link works node↔node but fails for a specific source IP:

```bash
ansible -i hosts.yml <host> -m shell -a \
    '(timeout 5 bash -c "</dev/tcp/<other-host>/<port>") && echo OPEN || echo CLOSED'
```

- **OCI**: NSGs attached to the VNIC. Defined in `terraform/main.tf` as
  `oci_core_network_security_group` + `oci_core_network_security_group_security_rule`.
  Rules UNION with the VCN default security list (which only opens `:22`
  + ICMP by default).
- **Other VPS providers**: check the provider control panel. OS-level
  iptables on these hosts is usually permissive.

## Step 6 — container-level DNAT

If a port is `0.0.0.0:<X>->container:<Y>` on the host but external dial
fails:

```bash
ansible -i hosts.yml <host> -m shell -b -a \
    "iptables -t nat -L DOCKER -nv | grep '<X>\\|<Y>'"
```

Missing DNAT rule means docker proxy created the binding but the iptables
rule didn't land — `docker compose down && up -d` usually re-creates it.

## Decision table

| Observation                                        | Likely cause                  | Where to fix                                                   |
|----------------------------------------------------|-------------------------------|----------------------------------------------------------------|
| Small OK, large stall, retransmits w/ backoff      | L3 path packet loss / sanctions | Move service off the bad route                               |
| Both stall, fast RST / no route                    | Cloud firewall denial         | Open NSG ingress (terraform/main.tf) or VCN security list      |
| Both stall, slow timeout                           | Wrong DNS / host not listening | Verify backend URL resolves + service actually binds          |
| Works from one IP only                             | Source-IP whitelist somewhere | Loosen NSG / check `DOCKER-USER` chain on the backend host    |
| Stall after fixed N bytes (≈ 98 KB)                | TCP window stuck — no ACKs    | Same as L3 packet loss row — symptom-identical                |
| "No route to host" via OS-level tcp probe          | NSG denial OR backend not listening | Check NSG rule first; if rule exists, check `ss -lntp` on backend |

## Don'ts

- Don't crank ocserv / xray MTU / MSS knobs to "fix" what is actually
  path-level loss. The packets get dropped before MSS matters.
- Don't add a permissive firewall rule "just to test" — once the rule
  lands on the prod NSG it tends to stay.
- Don't run `tcpdump -w` to disk on a VM with `<10 GB` free — it fills
  fast on busy interfaces. Use `-c <count>` or `-G <rotate-seconds>`.
