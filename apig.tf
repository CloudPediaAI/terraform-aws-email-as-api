locals {
  http_methods = {
    GET     = "GET",
    POST    = "POST",
    PUT     = "PUT",
    DELETE  = "DELETE",
    OPTIONS = "OPTIONS"
  }

  integration_types = {
    MOCK       = "MOCK",      # not calling any real backend
    AWS        = "AWS",       # for AWS services
    HTTP       = "HTTP",      # for HTTP backends 
    AWS_PROXY  = "AWS_PROXY"  # for Lambda proxy integration
    HTTP_PROXY = "HTTP_PROXY" # for HTTP proxy integration
  }

  auth_types = {
    NONE    = "NONE",
    CUSTOM  = "CUSTOM",
    AWSIAM  = "AWS_IAM",
    COGNITO = "COGNITO_USER_POOLS"
  }
}

resource "aws_api_gateway_rest_api" "messaging" {
  count = local.create_api_gateway ? 1 : 0

  name = "${var.api_name}-api"
  tags = var.tags
}

# create endpoints for each projects
resource "aws_api_gateway_resource" "project" {
  for_each = local.projects_need_api

  parent_id   = aws_api_gateway_rest_api.messaging[0].root_resource_id
  path_part   = each.key
  rest_api_id = aws_api_gateway_rest_api.messaging[0].id
}

locals {
  api_resource_ids = flatten([
    for key, value in aws_api_gateway_resource.project : [
      {
        id = aws_api_gateway_resource.project[key].id
      }
    ]
  ])

  api_method_ids = flatten([
    [
      for key, value in aws_api_gateway_method.send_email_post : [
        {
          id = aws_api_gateway_method.send_email_post[key].id
        }
      ]
    ],
    [
      for key, value in aws_api_gateway_method.send_email_options : [
        {
          id = aws_api_gateway_method.send_email_options[key].id
        }
      ]
    ]
  ])

  api_integration_ids = flatten([
    [
      for key, value in aws_api_gateway_integration.send_email_post : [
        {
          id = aws_api_gateway_integration.send_email_post[key].id
        }
      ]
    ],
    [
      for key, value in aws_api_gateway_integration.send_email_options : [
        {
          id = aws_api_gateway_integration.send_email_options[key].id
        }
      ]
    ]
  ])

  api_method_response_200_ids = flatten([
    [
      for key, value in aws_api_gateway_method_response.send_email_post_200 : [
        {
          id = aws_api_gateway_method_response.send_email_post_200[key].id
        }
      ]
    ],
    [
      for key, value in aws_api_gateway_method_response.send_email_options_200 : [
        {
          id = aws_api_gateway_method_response.send_email_options_200[key].id
        }
      ]
    ]
  ])

  api_method_response_400_ids = flatten([
    for key, value in aws_api_gateway_method_response.send_email_post_400 : [
      {
        id = aws_api_gateway_method_response.send_email_post_400[key].id
      }
    ]
  ])

  api_method_response_500_ids = flatten([
    for key, value in aws_api_gateway_method_response.send_email_post_500 : [
      {
        id = aws_api_gateway_method_response.send_email_post_500[key].id
      }
    ]
  ])

  api_integration_response_200_ids = flatten([
    [
      for key, value in aws_api_gateway_integration_response.send_email_post_200 : [
        {
          id = aws_api_gateway_integration_response.send_email_post_200[key].id
        }
      ]
    ],
    [
      for key, value in aws_api_gateway_integration_response.send_email_options_200 : [
        {
          id = aws_api_gateway_integration_response.send_email_options_200[key].id
        }
      ]
    ]
  ])

  api_integration_response_400_ids = flatten([
    for key, value in aws_api_gateway_integration_response.send_email_post_400 : [
      {
        id = aws_api_gateway_integration_response.send_email_post_400[key].id
      }
    ]
  ])

  api_integration_response_500_ids = flatten([
    for key, value in aws_api_gateway_integration_response.send_email_post_500 : [
      {
        id = aws_api_gateway_integration_response.send_email_post_500[key].id
      }
    ]
  ])

}

locals {
  resources_changed = flatten([
    length(local.api_resource_ids) > 0 ? local.api_resource_ids : [],
    length(local.api_method_ids) > 0 ? local.api_method_ids : [],
    length(local.api_integration_ids) > 0 ? local.api_integration_ids : [],
  ])
}

resource "aws_api_gateway_deployment" "main_deploy" {
  count = local.create_api_gateway ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.messaging[0].id

  triggers = {
    # NOTE: Only include basic API structure elements to avoid cycles
    # Integration responses are excluded to prevent circular dependencies
    redeployment = sha1(jsonencode(local.resources_changed))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_resource.project,
    aws_api_gateway_resource.send_email,
    aws_api_gateway_method.send_email_post,
    aws_api_gateway_method.send_email_options,
    aws_api_gateway_integration.send_email_post,
    aws_api_gateway_integration.send_email_options,
  ]
}

resource "aws_api_gateway_stage" "prod" {
  count = local.create_api_gateway ? 1 : 0

  deployment_id = aws_api_gateway_deployment.main_deploy[0].id
  rest_api_id   = aws_api_gateway_rest_api.messaging[0].id
  stage_name    = "prod_${var.api_version}"

  depends_on = [
    aws_api_gateway_deployment.main_deploy
  ]
}

resource "aws_api_gateway_base_path_mapping" "prod" {
  count = local.create_custom_domain ? 1 : 0

  api_id      = aws_api_gateway_rest_api.messaging[0].id
  stage_name  = aws_api_gateway_stage.prod[0].stage_name
  domain_name = aws_api_gateway_domain_name.api[0].domain_name
  base_path   = var.api_version
}

locals {
  api_base_url = local.create_api_gateway ? ((local.create_custom_domain) ? local.custom_api_url : aws_api_gateway_stage.prod[0].invoke_url) : ""
  # preparing a list of send-email API endpoints
  api_endpoints_send_email = flatten([
    for key, value in local.email_projects_need_api : {
      "${key}" = {
        "${key}-send-email" : "${local.api_base_url}${aws_api_gateway_resource.send_email[key].path}"
      }
    }
    ]
  )
  api_endpoints = concat(local.api_endpoints_send_email)
}

output "api_endpoints" {
  value       = local.api_endpoints
  description = "List of API endpoints created for messaging services"
}
