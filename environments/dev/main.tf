terraform {
  cloud {
    organization = "Soli"

    workspaces {
      name = "website-iac-dev"
    }
  }
}

module "application" {
  source = "../../application"

  environment = "dev"
}
