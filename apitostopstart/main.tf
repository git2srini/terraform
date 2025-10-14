# 1️⃣ IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-ec2-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 2️⃣ IAM Policy for EC2 + Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-ec2-api-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

# 3️⃣ Lambda Function
resource "aws_lambda_function" "ec2_control" {
  function_name = "ec2-api-control"
  filename      = "lambda_function2.zip"
  handler       = "lambda_function2.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      INSTANCE_IDS = "i-03cf7054c8f5f2cfd" # Replace with your EC2 Instance ID
    }
  }
}

# 4️⃣ API Gateway - Create REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "ec2-api"
  description = "API Gateway to start/stop EC2 via Lambda"
}

# 5️⃣ Create Resource /ec2
resource "aws_api_gateway_resource" "ec2_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "ec2"
}

# 6️⃣ POST Method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ec2_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# 7️⃣ Integration with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.ec2_resource.id
  http_method = aws_api_gateway_method.post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ec2_control.invoke_arn
}

# 8️⃣ Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  
  
}
resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "dev"
}


# 9️⃣ Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_control.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# 🔟 Output the API URL
output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-east-1.amazonaws.com/dev/ec2"
}
