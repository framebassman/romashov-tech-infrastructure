aiven_api_token = ""

project_name               = "romashov-tech"
pg_avnadmin_user_password  = ""
pg_foodikal_user_password  = ""
pg_inventory_user_password = ""
pg_outline_user_password   = ""
pg_vault_user_password     = ""

mysql_avnadmin_user_password   = ""
mysql_monitoring_user_password = ""

# OCI: VM и compartment захардкожены в модуле oci-vm и main.tf
oci_private_key = ""

# Алерт при достижении бюджета $5 (обязательно при использовании oci_budget_*)
oci_budget_alert_email = "your-email@example.com"
