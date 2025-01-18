
# Create IAM Users
resource "aws_iam_user" "programmatic_only" {
  for_each = toset(var.programmatic_only_users)
  name     = each.key
}

# Generate Programmatic Access Keys for ProgrammaticOnlyUsers
resource "aws_iam_access_key" "programmatic_only" {
  for_each = aws_iam_user.programmatic_only
  user     = each.value.name
}
# Save Programmatic Access Keys Locally for ProgrammaticOnlyUsers
resource "null_resource" "secure_programmatic_only" {
  for_each = aws_iam_user.programmatic_only

provisioner "local-exec" {
  command = <<EOT
    New-Item -ItemType Directory -Force -Path secure
    Set-Content -Path secure\\${each.key}_access_keys.csv -Value "User: ${each.key}`nAccess Key ID: ${aws_iam_access_key.programmatic_only[each.key].id}`nSecret Access Key: ${aws_iam_access_key.programmatic_only[each.key].secret}"
  EOT
  interpreter = ["PowerShell", "-Command"]
}

}


# Check if users exist before creating them
data "aws_iam_user" "existing_users" {
  for_each = toset(var.programmatic_only_users)

  user_name = each.key
  # This will throw an error if the user does not exist, so we use `null` to handle this.
  # In case the user exists, the data will be populated.
}

# Create IAM users only if they do not exist
resource "aws_iam_user" "programmatic_and_console" {
  for_each = { for user, _ in var.programmatic_and_console_users : user => _ if !contains([for u in data.aws_iam_user.existing_users : u.user_name], user) }

  name = each.key
}

# Create programmatic and console access keys for new users
resource "aws_iam_access_key" "programmatic_and_console" {
  for_each = { for user, _ in var.programmatic_and_console_users : user => _ if !contains([for u in data.aws_iam_user.existing_users : u.user_name], user) }

  user = aws_iam_user.programmatic_and_console[each.key].name
}



# Save Access Keys and Login Profile Information Locally for ProgrammaticAndConsoleUsers
resource "null_resource" "secure_programmatic_and_console" {
  for_each = aws_iam_user.programmatic_and_console

  provisioner "local-exec" {
  command = <<EOT
    $secureFolder = "./secure"
    $filePath = "$secureFolder\\${each.key}_credentials.csv"

    # Create secure folder if it doesn't exist
    if (-Not (Test-Path $secureFolder)) {
      New-Item -ItemType Directory -Path $secureFolder
    }

    # Write user credentials to the CSV file
    Set-Content -Path $filePath -Value @(
      "User: ${each.key}"
      "Access Key ID: ${aws_iam_access_key.programmatic_and_console[each.key].id}"
      "Secret Access Key: ${aws_iam_access_key.programmatic_and_console[each.key].secret}"
      "Console Login Password: See AWS Console (Password managed by AWS)"
    )

    # Set file permissions to make the file secure
    $acl = Get-Acl $filePath
    $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "Read", "Deny")))
    Set-Acl -Path $filePath -AclObject $acl
  EOT
  interpreter = ["PowerShell", "-Command"]
}

}