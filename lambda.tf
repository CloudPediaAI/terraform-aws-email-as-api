# create lambda package for send-email
data "archive_file" "lambda_pkg_send_email" {
  type        = "zip"
  source_file  = "${path.module}/send_email.js"
  output_path = "send-email-lambda.zip"
}

# create lambda for send-email
resource "aws_lambda_function" "send_email" {
  for_each = local.email_projects_need_api

  function_name    = "${var.api_name}-${each.key}-send-email"
  description      = "send emails using SES"
  filename         = "send-email-lambda.zip"
  source_code_hash = data.archive_file.lambda_pkg_send_email.output_base64sha256
  role             = aws_iam_role.lambda[each.key].arn
  runtime          = "nodejs20.x"
  handler          = "send_email.handler"
  timeout          = 180

  environment {
    variables = {
      "CURRENT_REGION": data.aws_region.current.name,
      "FROM_EMAIL_ID" : each.value.from_email
    }
  }

  tags = var.tags
}
