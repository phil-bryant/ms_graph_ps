#!/bin/bash

# #authored-by-ai #claude-3.7-sonnet-thinking 
# #autonomous-ai #cursor
# SPDX-License-Identifier: MIT

# Script to add a custom domain using interactive login.
# Usage: ./03_powershell_add_domain.sh yourdomain.com
set -e

# Check for domain name argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain-name>"
    exit 1
fi
DOMAIN_NAME="$1"
# Rename temporary file variables
TEMP_SCRIPT_FILE="03.output.powershell.ps1"
TEMP_OUTPUT_FILE="03.output.powershell.output.txt"

# Add cleanup: Move existing temp/output files to Trash if they exist
# Use -f with mv to suppress errors if files don't exist (though macOS mv doesn't have -f, it doesn't error)
echo "Checking for and moving old temporary files to Trash..."
[ -f "$TEMP_SCRIPT_FILE" ] && mv -v "$TEMP_SCRIPT_FILE" ~/.Trash/
[ -f "$TEMP_OUTPUT_FILE" ] && mv -v "$TEMP_OUTPUT_FILE" ~/.Trash/

# Create the temporary PowerShell script
# Modify the PowerShell script to output JSON with TTL
cat << EOF > "$TEMP_SCRIPT_FILE"
param(
    [string]\$DomainNameArg
)

Write-Host ("PowerShell script started for domain: " + \$DomainNameArg) -ForegroundColor Green -ErrorAction Continue

\$ErrorActionPreference = 'Stop' # Stop on errors to handle them

try {
    Import-Module Microsoft.Graph.Authentication -Function Connect-MgGraph -ErrorAction Stop
    Import-Module Microsoft.Graph.Identity.DirectoryManagement -Function New-MgDomain, Get-MgDomainVerificationDnsRecord -ErrorAction Stop

    # Use device code authentication for interactive login
    Connect-MgGraph -Scopes 'Directory.AccessAsUser.All','Domain.ReadWrite.All'

    Write-Host ("Attempting to add domain: " + \$DomainNameArg) -ForegroundColor Cyan -ErrorAction Continue
    # Suppress output from New-MgDomain, handle potential errors below
    New-MgDomain -Id \$DomainNameArg -ErrorAction Continue | Out-Null

    Write-Host ("Attempting to get verification records for: " + \$DomainNameArg) -ForegroundColor Cyan -ErrorAction Continue
    # Capture the verification record object
    \$verificationRecord = Get-MgDomainVerificationDnsRecord -DomainId \$DomainNameArg -ErrorAction Stop

    # Add a small delay and retry if the value is initially null
    if (\$verificationRecord -and -not \$verificationRecord.Text) {
        Write-Host "Initial verification record Text is null. Waiting 5 seconds and retrying..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        \$verificationRecord = Get-MgDomainVerificationDnsRecord -DomainId \$DomainNameArg -ErrorAction Stop
    }

    # Debug: Output the properties of the verification record
    # Remove debug output
    # if (\$verificationRecord) {
    #     Write-Host "Debug: Verification Record Properties:" -ForegroundColor Yellow
    #     \$verificationRecord | Format-List | Out-Host
    # } else {
    #     Write-Host "Debug: Verification Record object is null." -ForegroundColor Yellow
    # }

    if (\$verificationRecord) {
        # Filter for the TXT record if multiple types are returned (usually only one)
        \$txtRecord = \$verificationRecord | Where-Object { \$_.RecordType -eq 'Txt' } | Select-Object -First 1

        if (\$txtRecord) {
            # Construct the JSON output object
            \$outputObject = [PSCustomObject]@{
                type = \$txtRecord.RecordType
                # Use '@' for the root domain name, expected by Cloudflare/most DNS APIs
                name = "@" # \$txtRecord.Label # Usually '@' or the domain name itself
                value = \$txtRecord.AdditionalProperties.text # The verification string
                ttl = 300 # TTL in seconds (5 minutes)
            }
            # Convert the object to JSON and write ONLY that to standard output
            Write-Output (\$outputObject | ConvertTo-Json -Depth 3)
        } else {
            Write-Error "No TXT verification record found for \$DomainNameArg."
        }
    } else {
        Write-Error "Could not retrieve verification records for \$DomainNameArg. Domain might already exist or there was an API issue."
    }

} catch {
    Write-Error "An error occurred: \$(\$_.Exception.Message)"
    # Exit with a non-zero code to indicate failure within PowerShell
    exit 1
}

Write-Host ("PowerShell script finished for domain: " + \$DomainNameArg) -ForegroundColor Green -ErrorAction Continue
EOF

# Execute the temporary PowerShell script, passing the domain name
# Redirect ONLY stdout (JSON) to the output file. Keep stderr separate.
echo "Executing PowerShell script: $TEMP_SCRIPT_FILE"
pwsh -NoProfile -File "$TEMP_SCRIPT_FILE" "$DOMAIN_NAME" > "$TEMP_OUTPUT_FILE" 2> >(tee /dev/stderr) || true
PWSH_EXIT_CODE=$?

# Check if the output file was created and display its content
if [ -f "$TEMP_OUTPUT_FILE" ]; then
    echo "--- PowerShell Script Output (Exit Code: $PWSH_EXIT_CODE) ---"
    cat "$TEMP_OUTPUT_FILE"
    echo "------------------------------"
else
    echo "Error: PowerShell script did not produce an output file ($TEMP_OUTPUT_FILE), PWSH exit code: $PWSH_EXIT_CODE." >&2
fi

# Report if PowerShell script execution failed
if [ $PWSH_EXIT_CODE -ne 0 ]; then
    echo "Error: PowerShell script execution failed with exit code $PWSH_EXIT_CODE." >&2
fi

# Clean up temporary files
rm "$TEMP_SCRIPT_FILE"
# rm "$TEMP_OUTPUT_FILE" # Keep output file for debugging if needed

# Exit with the PowerShell script's exit code
exit $PWSH_EXIT_CODE
