# Root module entry point.
# Add shared AWS resources here or compose child modules from modules/.

module "website" {
  source = "../modules/website"

  name = "${var.project_name}-${var.environment}"
}