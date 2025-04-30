#!/bin/bash

# #authored-by-ai #gemini-2.5-pro
# #partially-human-reviewed
# SPDX-License-Identifier: MIT

# Script to fetch the required Microsoft 365 service configuration DNS records for a domain.
# Usage: ./05_powershell_show_domain_svc_recs.sh yourdomain.com
# Output: Writes JSON string containing the required DNS records to 05.output.powershell.output.txt

set -e # Exit immediately if a command exits with a non-zero status.
# set -o pipefail # Ensures that pipeline errors are caught

# Check for domain name argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain-name>" >&2
    exit 1
fi
DOMAIN_NAME="$1"
OUTPUT_FILE="05.output.powershell.output.txt"

echo "Attempting to fetch M365 service configuration records for domain: $DOMAIN_NAME" >&2

# Define the PowerShell command block
# We use single quotes around the domain name variable inside the PowerShell command
# to prevent Bash expansion issues and rely on PowerShell's variable handling.
# Connect-MgGraph requires Domain.Read.All scope.
# Get-MgDomainServiceConfigurationRecord retrieves the necessary records.
# ConvertTo-Json formats the results.
# ErrorAction Stop ensures pwsh exits non-zero if Get-MgDomainServiceConfigurationRecord fails.
# Standard output is the JSON, standard error shows progress messages.
POWERSHELL_COMMAND="
    # Use Write-Verbose for status messages so they don't pollute stdout
    Write-Verbose ('Importing required modules...') -Verbose
    Import-Module Microsoft.Graph.Authentication -Function Connect-MgGraph -ErrorAction Continue
    Import-Module Microsoft.Graph.Identity.DirectoryManagement -Function Get-MgDomainServiceConfigurationRecord -ErrorAction Continue

    Write-Verbose ('Connecting to Microsoft Graph...') -Verbose
    # Ensure Connect-MgGraph output (like Welcome message) doesn't go to stdout captured by Bash
    Connect-MgGraph -Scopes 'Domain.Read.All' -ErrorAction Stop | Out-Null # Stop if connection fails
    Write-Verbose ('Connected to Microsoft Graph.') -Verbose

    Write-Verbose ('Fetching service configuration records for domain: $DOMAIN_NAME ...') -Verbose
    
    \$records = Get-MgDomainServiceConfigurationRecord -DomainId '$DOMAIN_NAME' -ErrorAction Stop

    if (\$null -eq \$records -or \$records.Count -eq 0) {
        # Write-Error goes to stderr by default, which is fine.
        Write-Error ('No service configuration records found for $DOMAIN_NAME.')
        # Exit PowerShell with non-zero code if no records found
        exit 1 
    } else {
        Write-Verbose (\"Successfully retrieved \$(\$records.Count) records.\") -Verbose
        # Only this Write-Output should go to stdout
        Write-Output (\$records | ConvertTo-Json -Depth 5)
    }
"

# Execute the PowerShell command inline
# Capture stdout (the JSON output) into a variable.
# Redirect pwsh stderr (progress messages, errors) to the script's stderr, prefixing lines.
echo "Running PowerShell command..." >&2
JSON_OUTPUT=$(pwsh -NoProfile -Command "$POWERSHELL_COMMAND" 2> >(sed 's/^/  [pwsh stderr] /' >&2))

PWSH_EXIT_CODE=$?

if [ $PWSH_EXIT_CODE -eq 0 ]; then
    echo "PowerShell command executed successfully." >&2
    # Write the captured JSON output to the file
    echo "Writing output to $OUTPUT_FILE..." >&2
    echo "$JSON_OUTPUT" > "$OUTPUT_FILE"
    # Check if file write was successful (basic check)
    if [ -s "$OUTPUT_FILE" ]; then
        echo "Service configuration records successfully written to $OUTPUT_FILE." >&2
    else
        echo "Error: Failed to write output to $OUTPUT_FILE." >&2
        exit 1 # Indicate failure
    fi
else
    echo "Error: PowerShell command failed with exit code $PWSH_EXIT_CODE." >&2
fi

exit $PWSH_EXIT_CODE 