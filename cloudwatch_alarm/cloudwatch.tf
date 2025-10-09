

# Create a Log Group
resource "aws_cloudwatch_log_group" "example_log_group" {
  name              = "/terraform/example-log-group"
  retention_in_days = 7
}

# Create a Metric Alarm for EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high_cpu_utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors EC2 CPU utilization"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.linux1.id
  }

  alarm_actions = ["arn:aws:automate:us-east-1:ec2:stop"]
}

# Create a CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "example_dashboard" {
  dashboard_name = "EC2-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.linux1.id ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
