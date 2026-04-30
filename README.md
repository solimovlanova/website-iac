# website-iac

Terraform AWS starter structure.

This scaffold is configured for Terraform Cloud with organization `Soli` and workspace `website`.

## Layout

- `versions.tf`: Terraform and provider version constraints
- `providers.tf`: AWS provider configuration
- `locals.tf`: shared tags and naming values
- `variables.tf`: input variables
- `outputs.tf`: root outputs
- `modules/website`: example reusable module
- `environments/dev` and `environments/prod`: environment-specific placeholders