locals {
  name = "${lower(var.name)}-${terraform.workspace}"
  tags = merge({
    Environment = terraform.workspace
  }, var.tags)
}

data "aws_s3_bucket_object" "artifact_file" {
  bucket = var.s3_bucket
  key    = var.s3_key
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
    sid    = "LambdaAssumeRolePolicy"
  }
}

resource "aws_lambda_function" "function" {
  function_name = local.name
  handler       = var.handler
  memory_size   = var.memory_size
  role          = aws_iam_role.function_role.arn
  runtime       = "java11"
  tags          = local.tags
  timeout       = var.timeout

  s3_bucket = data.aws_s3_bucket_object.artifact_file.bucket
  s3_key    = data.aws_s3_bucket_object.artifact_file.key

  environment {
    variables = merge({
      ENVIRONMENT = terraform.workspace
    }, var.environment_variables)
  }
}

resource "aws_iam_role" "function_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "${local.name}-execution-${data.aws_region.current.name}"
  tags               = local.tags
}

resource "aws_iam_policy" "role_policy" {
  policy = var.policy_json
  name   = "${local.name}-execution-policy-${data.aws_region.current.name}"
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.role_policy.arn
  role       = aws_iam_role.function_role.name
}

resource "aws_cloudwatch_event_rule" "cron_rule" {
  name                = "${local.name}-trigger-${data.aws_region.current.name}"
  description         = "Used to trigger lambda ${local.name}"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
  rule      = aws_cloudwatch_event_rule.cron_rule.name
  target_id = "check_foo"
  arn       = aws_lambda_function.function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_rule.arn
}