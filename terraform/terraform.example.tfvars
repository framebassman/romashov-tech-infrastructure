vdsina_ru_api_token  = ""
vdsina_com_api_token = ""

aiven_api_token = ""

project_name               = "romashov-tech"
pg_avnadmin_user_password  = ""
pg_foodikal_user_password  = ""
pg_inventory_user_password = ""
pg_outline_user_password   = ""
pg_vault_user_password     = ""
pg_mtproxy_user_password   = ""

# OCI: VM и compartment захардкожены в модуле oci-vm и main.tf
oci_private_key = ""

# Grafana Cloud (modules/grafana-monitoring) — все значения из Cloudflare KV.
# grafana_stack_slug дефолтится в "romashovtech" в variables.tf — переопредели
# только если slug изменился.
grafana_cloud_api_key              = "" # KV: grafana_cloud_api_key
grafana_synthetic_monitoring_token = "" # KV: GRAFANA_SYNTHETIC_MONITORING_TOKEN
