# Create IAM User Groups
resource "aws_iam_group" "teams" {
  for_each = toset(var.teams)
  name = each.key
}