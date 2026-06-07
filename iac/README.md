# SFM Website IaC

This directory intentionally keeps the first pass simple.

- `main.tf` is a single flat OpenTofu root for the phase-1 AKS-hosted static site.
- `upload-static.ps1` uploads the full `static/` directory into the blob container mounted by nginx.

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

## Expected flow

1. Run `tofu init`.
2. Run `tofu plan`.
3. Apply when ready.
4. Upload site content with `.\upload-static.ps1`.
5. Delegate the registrar to the Azure DNS zone nameservers after reviewing the `dns_name_servers` output.

## Not in scope yet

- Namecheap delegation automation
- Analytics or backend services
- GitHub Actions deployment automation
