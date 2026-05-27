output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.principal.id
}

output "subnet_ids" {
  description = "Lista com os IDs das subnets públicas criadas (1a e 1b)"
  value       = [aws_subnet.publica_1a.id, aws_subnet.publica_1b.id]
}
