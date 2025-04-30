# MS Graph PowerShell Domain Management Scripts

# #authored-by-ai #gemini-2.5-pro
# #autonomous-ai #cursor
# SPDX-License-Identifier: MIT

This account was created and is owned by a real human, however, be advised that THIS REPO WAS AUTONOMOUSLY PUBLISHED BY AN AI via execution of ./01_create_github_repo.sh --personal --public

This project provides scripts to manage custom domains in Microsoft 365 using PowerShell and the Microsoft Graph SDK. The primary goal is to automate the process of adding a custom domain, retrieving the necessary DNS verification records, and retrieving the service configuration records needed for full functionality.

See the [Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/admin/get-help-with-domains/create-dns-records-at-any-dns-hosting-provider?view=o365-worldwide) for more background on DNS records.

## Scripts: M365 Custom Domains - Cradle to Grave 

The core scripts (numbered 02-05) are designed to be run in sequence to add, verify, configure, and/or ultimately remove a custom domain.

- `01_create_github_repo.sh`: (Setup) Initializes this GitHub repository. Not part of the domain workflow.
- `02_install_powershell.sh`: (Setup) Installs PowerShell using Homebrew (for macOS). Run once if needed.
- `03_powershell_add_domain.sh`: (Step 1) Adds a custom domain to your M365 tenant via `Connect-MgGraph` and outputs the required TXT verification record details to `03.output.powershell.output.txt`.
- `04_powershell_confirm_domain.sh`: (Step 3) Triggers the domain verification process within Microsoft 365 via `Connect-MgGraph` and the `Confirm-MgDomain` cmdlet. This should be run *after* the TXT record from script 03 has been successfully added to your public DNS.
- `05_powershell_show_domain_svc_recs.sh`: (Step 4) Fetches the required Microsoft 365 service configuration DNS records (MX, CNAME, SRV, etc.) for a *verified* domain via `Connect-MgGraph` and outputs the details to `05.output.powershell.ouput.txt`. This is needed to complete the domain setup for services like Exchange Online, Teams, etc. *after* script 04 confirms verification.
- `06_powershell_remove_domain.sh`: (Utility) Removes a specified custom domain from your M365 tenant via `Connect-MgGraph`.

## Workflow

1. **Prerequisites:** Run `02_install_powershell.sh` if PowerShell isn't installed.
2. **Add Domain:** Run `03_powershell_add_domain.sh <yourdomain.com>`. This adds the domain to M365 and outputs the TXT verification record details to `03.output.powershell.output.txt`.
3. **Add TXT Record:** Add the TXT record from `03.output.powershell.output.txt` to your domain's DNS zone (e.g., using Cloudflare scripts in the related [clouflare_api_client](https://github.com/phil-bryant/cloudflare_api_client) repo or your DNS provider's interface). Wait for DNS propagation.
4. **Confirm Domain:** Run `04_powershell_confirm_domain.sh <yourdomain.com>`. This tells M365 to check for the TXT record that you just put in 3.
5. **Get Service Records:** Run `05_powershell_show_domain_svc_recs.sh <yourdomain.com>`. Run this after you are able to confirm/verify your domain in 4. This gets the DNS records MSFT wants, e.g., CNAME, SRV, etc., records needed for M365 services, saving them to `05.output.powershell.ouput.txt`. Add the records from `05.output.powershell.ouput.txt` to your domain's DNS zone (e.g., using Cloudflare scripts in the related [clouflare_api_client](https://github.com/phil-bryant/cloudflare_api_client) repo or your DNS provider's interface). Wait for DNS propagation.

## Support

Please note that this repository is maintained primarily by autonomous AI agents. There is no guarantee that the human developer that created and owns this account will review your issues or pull requests.

An AI agent may review submitted issues and pull requests. However, there is no guarantee that the AI will choose to address them, nor that any AI-driven changes will be satisfactory.

The AI first screens all submissions for malicious intent or content. Malicious issues or pull requests will be reported to the various warranted channels.
