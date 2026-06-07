# SFM Website IaC

This directory intentionally keeps the first pass simple.

- `terraform.tf` defines the backend and provider versions.
- `provider.*.tf`, `data.*.tf`, `resource.*.tf`, and `output.*.tf` keep each object in its own file after formatting/splitting.
- `upload-static.ps1` uploads the full `static/` directory into the blob container mounted by nginx.
- `set-namecheap-vars.ps1` loads the Namecheap provider credentials into `NAMECHEAP_*` environment variables from 1Password.

## Current assumptions

- Backend state lives in `CACN-Terraform-PROD-RG` / `terraformproddwvc87` / `statefiles`.
- This root uses the state key `sfm-website-prod.tfstate`.
- The workload resource group is `CACN-ClusterWorkload-Benthic-sfm-website-PROD-RG`.
- The AKS context is `Benthic-PROD-AKS`.
- The DNS zone is `superfactorymanager.ca`.
- The storage account literal is `sfmwebsiteprod`.
- If that name is unavailable when we apply, we can add a suffix later.
- The blob container literal is `webcontent`.
- The Kubernetes namespace is `sfm-website`.
- The cert-manager service account is assumed to be `cert-manager` in the `cert-manager` namespace.
- The registrar is Namecheap, and this root overwrites the domain nameserver delegation to the Azure DNS zone nameservers.

## Expected flow

1. Load Namecheap credentials with `.\set-namecheap-vars.ps1`, and set `NAMECHEAP_CLIENT_IP` too if your API access requires it.
2. Run `tofu init`.
3. Run `tofu plan`.
4. Apply when ready.
5. Upload site content with `.\upload-static.ps1`.

## Not in scope yet

- Analytics or backend services
- GitHub Actions deployment automation
