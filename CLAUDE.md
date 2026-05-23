# romashov-tech-infrastructure

Orchestration repo. No application code, no docker-compose files. Two halves:

- `ansible/` — deploy / backup / restore playbooks + roles. Inventory in `hosts.yml`.
- `terraform/` — OCI VM + IAM, Aiven managed databases. State in Cloudflare R2
  (s3-compatible) at `kolenka-inc-terraform-backend`.

Compose stacks live in the sibling repo `romashov-tech`. The
`romashov-tech-deployment` role clones it onto each host and runs the
matching Makefile target at deploy time.

## Standard deploy pattern

Each service has a thin playbook `playbooks/deploy-<service>.yml`:
```yaml
- hosts: <inventory-group>
  become: true
  become_user: d.romashov
  vars:
    application: <make-target-suffix>
    project_path: /home/d.romashov/romashov-tech
  roles:
    - romashov-tech-deployment
```

The role:
1. Copies `ssh-config` referencing `~/.ssh/github_actions_id_rsa`.
2. Clones `romashov-tech` to `project_path` (or `git reset --hard` if it exists).
3. `make stop-prod-{{ application }}`.
4. `make start-prod-{{ application }}`.
5. `docker image prune --all --force`.

To add a new service: new playbook + add `application` matching a Makefile
target in the app repo. To add a new host: add to `hosts.yml` with `fqdn`,
copy the GitHub deploy key onto the host before first deploy.

## Inventory groups

| Group        | Hosts                                | Notes                                                  |
|--------------|--------------------------------------|--------------------------------------------------------|
| `russian`    | 109.172.90.19 (node2)                | RU edge — traefik + 3x-ui-in                           |
| `dutch`      | 91.84.124.164 + 185.121.233.152      | NL hosts                                               |
| `sweden`     | 79.76.37.36 (OCI Stockholm)          | grafana-alloy only — outbound-only                     |
| `vpn`        | 91.84.124.164 + 109.172.90.19        | openconnect ocserv hosts                               |
| `mtproxy`    | 91.84.124.164                        | telegram mtproxy                                       |
| `_3xui`      | 109.172.90.19 + 185.121.233.152      | host var `direction: in|out` picks compose-profile      |
| `monitoring` | 91.84.124.164                        | uptime-kuma                                            |

Every host has `fqdn` set in inventory — roles assume it.

## CI workflow caveats (`.github/workflows/deploy.yml`)

Triggered on **every `pull_request`** against master:
1. `apply-terraform-modules` — runs `terraform apply -auto-approve` against
   real OCI / Aiven state. Will mutate cloud state on every PR, even
   docs-only PRs.
2. `apply-infrastructure-playbook` — provisioning basics.
3. `apply-firewall-playbook` + `apply-3xui-playbook` (in parallel after #2)
   — both auto-deploy to real hosts. The 3x-ui playbook will recreate
   `3xui_app` containers (~10s downtime per host).

Implications:
- A docs-only PR still runs terraform apply. Watch for side effects.
- To suppress autodeploy on a given PR: `gh run cancel <id>` after opening.
- The `apply-terraform-modules` job uses
  `terraform apply -auto-approve`, so any drift between the branch and
  master will be applied on PR open.

## GitHub deploy keys on hosts

`roles/romashov-tech-deployment/files/ssh-config` references
`~/.ssh/github_actions_id_rsa`. Every host needs that private key plus a
matching deploy key registered on the `romashov-tech` repo. When
provisioning a new host the role fails on `git clone` with
`Permission denied (publickey)`. Fix:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_actions_id_rsa -N "" -C "github-deploy-<host>"
cat ~/.ssh/github_actions_id_rsa.pub   # add to GitHub repo Deploy Keys
```

## OCI sweden quirks

- Uses an existing VCN `vcn-20250808-1700` (not managed by terraform); we
  attach a subnet + VM only.
- Subnet's default security list = `:22` + ICMP only. Open extra ports
  via an NSG (`oci_core_network_security_group` + security rules), attach
  via `module.oci_vm.nsg_ids`. NSG rules **UNION** with the security list
  at evaluation time.
- **Destroy ordering trap**: removing `nsg_ids` from VNIC *and* destroying
  the NSG in the same plan races — OCI rejects NSG delete while VNIC
  still references it. Do detach-first apply, then delete in a follow-up
  PR. There is currently an empty `oci_core_network_security_group
  "sweden_inbound"` retained for this reason; safe to delete now in a
  follow-up.
- Default NIC MTU on OCI is 9000 (jumbo). MSS clamping usually saves us,
  but keep in mind if a future inbound service shows the 98 KB stall
  symptom.
- **RU peering**: do not host services on sweden that need to be
  reverse-proxied from node2 (RU). Large TCP transfers stall —
  see `.claude/skills/diagnose-cross-node-link`.

## Backup / restore (3x-ui only)

- `.github/workflows/backup-3x.yml` runs `playbooks/backup-3x-ui.yml`
  daily at 03:00 UTC.
- Archive layout: R2 bucket `backups`, key
  `<fqdn>/backup-YYYY-MM-DDTHH-MM-SS.tar`.
- Retention: `backup_retention_count` (default 5) defined in
  `roles/3x-ui/defaults/main.yml`. **Don't delete that file** — backup
  task depends on it (this cron broke once already when the file was
  removed during a role-trim).
- Restore: `playbooks/restore-3x-ui.yml` with
  `--extra-vars backup_filename=<basename>` (omit for latest).
- Backup stops the `3xui_app` container before tar-ing the volume on
  disk → brief downtime during backup window.

## Known issues

- `romashov-tech/.github/workflows/vpn-deploy.yml` path filter has
  `docker-compose.vpn.yml` without `deploy/` prefix — workflow doesn't
  fire on the actual compose file changes. Run `make deploy-vpn`
  manually after vpn.yml edits or fix the path filter.
- Empty `oci_core_network_security_group "sweden_inbound"` retained in
  `terraform/main.tf` for the destroy-race reason above. Safe to remove
  in a follow-up.

## Hard no's

(Apply on top of the workspace-level `claude.md` rules.)

- Do not run `ansible-playbook` against real inventory without `--check`
  unless explicitly told to in the current turn.
- Do not run `make apply` or `terraform apply / destroy / state mv / state rm` without
  explicit OK in the current turn.
- Do not add `apply-*` CI jobs that run against prod without a manual
  approval gate.
- Do not commit `terraform.tfvars`, `backend.conf` in plaintext, or any
  files containing real secret material.
