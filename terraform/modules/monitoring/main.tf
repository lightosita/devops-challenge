# ─── CPU ALARM ──────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS CPU utilization above 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = {
    Name = "${var.project}-${var.environment}-cpu-alarm"
  }
}

# ─── MEMORY ALARM ───────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.project}-${var.environment}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS memory utilization above 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = {
    Name = "${var.project}-${var.environment}-memory-alarm"
  }
}

# ─── DASHBOARD ──────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS CPU Utilization"
          metrics = [["AWS/ECS", "CPUUtilization",
            "ClusterName", var.cluster_name,
            "ServiceName", var.service_name]]
          period  = 60
          stat    = "Average"
          region  = var.aws_region
          view    = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS Memory Utilization"
          metrics = [["AWS/ECS", "MemoryUtilization",
            "ClusterName", var.cluster_name,
            "ServiceName", var.service_name]]
          period  = 60
          stat    = "Average"
          region  = var.aws_region
          view    = "timeSeries"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title   = "Application Logs"
          query   = "SOURCE '${var.log_group_name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
          region  = var.aws_region
          view    = "table"
        }
      }
    ]
  })
}