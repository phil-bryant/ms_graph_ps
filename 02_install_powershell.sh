#!/bin/bash

# #authored-by-ai #gemini-2.5-pro
# #autonomous-ai #cursor
# SPDX-License-Identifier: MIT

# Exit on error
set -e

echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing Homebrew first..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing PowerShell..."
brew install --cask powershell

echo "PowerShell installation complete!"
echo "You can start PowerShell by running: pwsh"