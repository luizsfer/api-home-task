resource "aws_apigatewayv2_api" "user_api" {
  name          = "user_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "user_api" {
  api_id = aws_apigatewayv2_api.user_api.id

  name        = "user_api"
  auto_deploy = true

  access_log_settings {
    destination_arn = var.cloudwatch_log_group_arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "user_api_get" {
  api_id           = aws_apigatewayv2_api.user_api.id
  integration_type = "AWS_PROXY"
  integration_method = "GET"
  integration_uri  = var.lambda_integration_uri

}

resource "aws_apigatewayv2_route" "route_user_api_get" {
  api_id    = aws_apigatewayv2_api.user_api.id
  route_key = "GET /hello/{username}"
  target    = "integrations/${aws_apigatewayv2_integration.user_api_get.id}"
}

resource "aws_apigatewayv2_integration" "user_api_put" {
  api_id           = aws_apigatewayv2_api.user_api.id
  integration_type = "AWS_PROXY"
  integration_method = "PUT"
  integration_uri  = var.lambda_integration_uri

}

resource "aws_apigatewayv2_route" "route_user_api_put" {
  api_id    = aws_apigatewayv2_api.user_api.id
  route_key = "PUT /hello/{username}"
  target    = "integrations/${aws_apigatewayv2_integration.user_api_put.id}"
}