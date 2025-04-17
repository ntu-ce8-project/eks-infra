# Create new OIDC provider and role for GitHub Actions

To create just the OIDC role, run:

```sh
terraform plan -out tfplan
terraform apply tfplan
```

Set `create_oidc_provider` to `true` to create both the OIDC provider and role:

```sh
terraform plan -var "create_oidc_provider=true" -out tfplan
terraform apply tfplan
```
