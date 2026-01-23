# OPTIONS Method
resource "aws_api_gateway_method" "send_email_options" {
  for_each = aws_api_gateway_resource.send_email

  resource_id = each.value.id
  rest_api_id = aws_api_gateway_resource.project[each.key].rest_api_id
  http_method   = local.http_methods.OPTIONS
  authorization = "NONE"
}

# OPTIONS Method Response
resource "aws_api_gateway_method_response" "send_email_options_200" {
  for_each = aws_api_gateway_resource.send_email

  rest_api_id = aws_api_gateway_rest_api.messaging[0].id
  resource_id = aws_api_gateway_resource.send_email[each.key].id
  http_method = aws_api_gateway_method.send_email_options[each.key].http_method
  status_code = "200"

  response_parameters = local.common_res_params

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [ aws_api_gateway_method.send_email_options ]
}

# OPTIONS Integration (Mock)
resource "aws_api_gateway_integration" "send_email_options" {
  for_each = aws_api_gateway_resource.send_email

  rest_api_id = aws_api_gateway_rest_api.messaging[0].id
  resource_id = aws_api_gateway_resource.send_email[each.key].id
  http_method = aws_api_gateway_method.send_email_options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [ aws_api_gateway_method.send_email_options ]
}

# OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "send_email_options_200" {
  for_each = aws_api_gateway_resource.send_email

  rest_api_id = aws_api_gateway_rest_api.messaging[0].id
  resource_id = aws_api_gateway_resource.send_email[each.key].id
  http_method = aws_api_gateway_method.send_email_options[each.key].http_method
  status_code = aws_api_gateway_method_response.send_email_options_200[each.key].status_code

  response_parameters = local.common_res_params_responses

  depends_on = [
    aws_api_gateway_method.send_email_options,
    aws_api_gateway_integration.send_email_options
    ]
}