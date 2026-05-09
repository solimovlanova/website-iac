terraform {
  cloud {
    organization = "Soli"

    workspaces {
      name = "website-iac"
    }
  }
}

module "application" {
  source = "../../application"

  environment = "prod"
}
