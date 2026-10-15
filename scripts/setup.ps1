param([string]$TargetDir = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
& (Join-Path (Split-Path $PSScriptRoot -Parent) 'setup-dev-env.ps1') -TargetDir $TargetDir
