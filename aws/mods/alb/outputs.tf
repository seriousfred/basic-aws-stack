output "listener_arn" {
  value = (var.create_alb == true
  ? (length(aws_alb_listener.http_listener) > 0 ? aws_alb_listener.http_listener[0].arn : "") : "")
}