# Create IAM users and add them to the group
resource "aws_iam_user" "DevTeam" {
  for_each = toset(var.iam_usernames_DevTeam)
  name     = each.value
}

# #create access key ID and secret key 
# resource "aws_iam_access_key" "terraform-user_access_key" {
#   user = aws_iam_user.terraform-user.name
# }
# output "access_key_id" {
#   value = aws_iam_access_key.terraform-user_access_key
#   sensitive = true
# }
# output "secret_access_key" {
#   value = aws_iam_access_key.terraform-user_access_key.secret
#   sensitive = true
# }
# locals {
#   terraform-user_keys_csv = "access_key,secret_key\n${aws_iam_access_key.terraform-user_access_key.id},${aws_iam_access_key.terraform-user_access_key.secret}"
# } 
# resource "local_file" "terraform-user_keys" {
#   content  = local.terraform-user_keys_csv
#   filename = "terraform-user-keys.csv"
# }