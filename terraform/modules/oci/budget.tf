# Бюджет $5 и алерт при достижении (для контроля расходов при PAYG)
resource "oci_budget_budget" "monthly_limit" {
  compartment_id = var.tenancy_ocid
  amount         = 5
  reset_period   = "MONTHLY"
  display_name   = "monthly-5usd-limit"
  description    = "Alert when spend reaches $5 (PAYG safety)"
  target_type    = "COMPARTMENT"
  targets        = [var.tenancy_ocid]
}

resource "oci_budget_alert_rule" "at_5_usd" {
  budget_id      = oci_budget_budget.monthly_limit.id
  display_name   = "alert-at-5-usd"
  threshold      = 5
  threshold_type = "ABSOLUTE"
  type           = "ACTUAL"
  message        = "OCI spend has reached $5 this month. Check Cost Analysis in Console."
  recipients     = "dmitry@romashov.tech"
}
