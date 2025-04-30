#!/bin/bash

# #authored-by-ai #gemini-pro-1.5
# #autonomous-ai #cursor
# SPDX-License-Identifier: MIT

# Script to trigger verification of a custom domain using interactive login.
# Assumes the necessary DNS TXT record has already been created.
# Usage: ./04_powershell_confirm_domain.sh yourdomain.com

set -e

# Check for domain name argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain-name>"
    exit 1
fi
DOMAIN_NAME="$1"

# Remove temporary file logic
# TEMP_SCRIPT_FILE="05.output.powershell.ps1"
# echo "Cleaning up old temporary script file if it exists..."
# mv "$TEMP_SCRIPT_FILE" ~/.Trash/ 2>/dev/null || true
# echo "Cleanup check complete."

echo "Attempting to trigger verification for domain: $DOMAIN_NAME"

# Execute PowerShell command inline like script 04
pwsh -NoProfile -Command "
    Write-Host ('Importing required modules...') -ErrorAction Continue
    Import-Module Microsoft.Graph.Authentication -Function Connect-MgGraph -ErrorAction Continue
    Import-Module Microsoft.Graph.Identity.DirectoryManagement -Function Confirm-MgDomain -ErrorAction Continue

    Write-Host ('Connecting to Microsoft Graph...') -ErrorAction Continue
    Connect-MgGraph -Scopes 'Directory.AccessAsUser.All','Domain.ReadWrite.All' -ErrorAction Continue

    Write-Host ('Triggering verification for domain: $DOMAIN_NAME ...') -ErrorAction Continue
    # Use ErrorAction Stop here to make pwsh exit non-zero on failure
    Confirm-MgDomain -DomainId '$DOMAIN_NAME' -Verbose -ErrorAction Stop

    # If Confirm-MgDomain succeeds, print success message
    Write-Host ('Verification check triggered successfully for $DOMAIN_NAME.') -ForegroundColor Green -ErrorAction Continue
    Write-Host ('Check the Microsoft 365 admin center for the updated domain status.') -ErrorAction Continue
" | cat

PWSH_EXIT_CODE=$?

# Remove cleanup logic
# rm "$TEMP_SCRIPT_FILE"

if [ $PWSH_EXIT_CODE -eq 0 ]; then
    echo "Verification command executed successfully."
else
    echo "Error: PowerShell script execution failed with exit code $PWSH_EXIT_CODE." >&2
fi

exit $PWSH_EXIT_CODE 