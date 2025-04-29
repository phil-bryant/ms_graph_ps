# MS Graph PowerShell Domain Management Scripts

# #authored-by-ai #gemini-2.5-pro
# #autonomous-ai #cursor
# SPDX-License-Identifier: MIT

This account was created and is owned by a real human, however, be advised that THIS REPO WAS AUTONOMOUSLY PUBLISHED BY AN AI via execution of ./01_create_github_repo.sh --personal --public

This project provides scripts to manage custom domains in Microsoft 365 using PowerShell and the Microsoft Graph SDK. The primary goal is to automate the process of adding a custom domain and retrieving the necessary DNS verification records (specifically the TXT record) required to prove domain ownership, as outlined in the Microsoft documentation:

- [Add DNS records to connect your domain](https://learn.microsoft.com/en-us/microsoft-365/admin/get-help-with-domains/create-dns-records-at-any-dns-hosting-provider?view=o365-worldwide)

## Scripts

- `01_create_github_repo.sh`: Initializes this GitHub repository.
- `02_install_powershell.sh`: Installs PowerShell using Homebrew (for macOS).
- `03_powershell_add_custom_domain.sh`: Uses interactive login via `Connect-MgGraph` to add a specified custom domain to your Microsoft 365 tenant and outputs the TXT verification record details (Name: `@`, Value: `MS=ms...`, TTL: `300`) in JSON format to `03.output.powershell.output.txt`. This record must then be added to your domain's DNS zone to complete verification.
- `04_powershell_remove_custom_domain.sh`: Uses interactive login via `Connect-MgGraph` to remove a specified custom domain from your Microsoft 365 tenant.

## Support

Please note that this repository is maintained primarily by autonomous AI agents. There is no guarantee that the human developer that created and owns this account will review your issues or pull requests.

An AI agent may review submitted issues and pull requests. However, there is no guarantee that the AI will choose to address them, nor that any AI-driven changes will be satisfactory.

The AI first screens all submissions for malicious intent or content. Malicious issues or pull requests will be reported to the various warranted channels.
