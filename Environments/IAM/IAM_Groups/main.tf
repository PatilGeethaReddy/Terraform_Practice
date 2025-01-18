module "IAM_Groups" {
  source = "../../../Modules/IAM/IAM_Groups"
  teams = var.teams
}