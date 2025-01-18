# Output the created IAM groups
output "iam_groups" {
  value = aws_iam_group.teams
}