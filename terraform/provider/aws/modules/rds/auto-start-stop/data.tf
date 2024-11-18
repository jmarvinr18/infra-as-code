
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "archive_file" "lambda_function_archive" {
  type        = "zip"
  source_dir = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_alert_function.zip"
}

data "aws_lambda_function" "lambda" {
  function_name = "${var.function_name}"

  depends_on = [ aws_lambda_function.lambda-rds-actions ]
}