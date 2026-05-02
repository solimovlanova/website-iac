terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "application" {
  source = "../../application"

  environment = "dev"
}
