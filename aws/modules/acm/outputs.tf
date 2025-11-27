output "certificate_arn" {
  description = "ARN of the certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.main[0].arn : ""
}