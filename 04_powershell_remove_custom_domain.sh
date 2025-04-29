#!/bin/bash

## #human-authored
## author: https://github.com/phil-bryant
## SPDX-License-Identifier: MIT

set -e
pwsh -Command "
    Import-Module Microsoft.Graph.Authentication -Function Connect-MgGraph -ErrorAction SilentlyContinue
    Import-Module Microsoft.Graph.Identity.DirectoryManagement -Function Remove-MgDomain -ErrorAction SilentlyContinue
    Connect-MgGraph -Scopes 'Directory.AccessAsUser.All','Domain.ReadWrite.All' -ErrorAction SilentlyContinue
    Remove-MgDomain -DomainId $1 -Verbose" | cat
