module "bank31_ecr" {
  source = "./modules/ecr"

  repo_names = {
    frontend = "bank31-frontend"
    backend  = "bank31-backend"
  }
}
