resource "aws_sns_topic" "sns_notifications" {
  name = var.topic_name
}