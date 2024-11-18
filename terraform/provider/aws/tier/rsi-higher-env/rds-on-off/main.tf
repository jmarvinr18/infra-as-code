

module "lambda_downtime_and_live_scheduler" {
  source = "../../../modules/rds/auto-start-stop"

  function_name  = "${title(var.env)}-RDSONandOffInstanceServer"
  handler        = "index.handler"
  runtime        = "nodejs16.x"
  timeout        = 100

  environment = {
    variables = {
      ENVIRONMENT = "${var.env}",
      DB_INSTANCE_IDS = jsonencode(var.instance_ids)
    }
  }
}
 