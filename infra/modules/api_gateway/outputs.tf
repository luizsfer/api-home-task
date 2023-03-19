output "execution_arn_get" {
  value = "${aws_apigatewayv2_api.user_api.execution_arn}/*/*"
}

output "stage_name" {
  value = aws_apigatewayv2_stage.user_api.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.user_api.invoke_url
}