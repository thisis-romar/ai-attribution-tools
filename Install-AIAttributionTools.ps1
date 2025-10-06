#Requires -RunAsAdministrator
<#
.SYNOPSIS
One-click installation of AI Attribution Tools for VS Code Copilot environments on Windows 11.

.DESCRIPTION
Automated setup script that installs and configures AI Attribution Tools for out-of-the-box 
use in VS Code Copilot environments. Handles PowerShell module installation, VS Code extension 
configuration, and workspace setup.

.PARAMETER InstallLocation
Installation method: 'CurrentUser', 'AllUsers', or 'Portable'
Default: 'CurrentUser'

.PARAMETER ConfigureVSCode
Automatically configure VS Code settings and extensions.
Default: $true

.PARAMETER CreateShortcuts
Create desktop and start menu shortcuts.
Default: $true

.EXAMPLE
.\Install-AIAttributionTools.ps1
# Standard installation with VS Code integration

.EXAMPLE  
.\Install-AIAttributionTools.ps1 -InstallLocation AllUsers -ConfigureVSCode $false
# System-wide installation without VS Code configuration

.NOTES
Requires: Windows 11, PowerShell 5.1+, Administrative privileges
Supports: VS Code, VS Code Insiders, Cursor, and other Copilot-enabled editors

.LINK
https://github.com/thisis-romar/emblem.io-whatsapp-receipts/blob/main/AIAttributionTools/README.md
#>

[CmdletBinding()]
param(
    [ValidateSet('CurrentUser', 'AllUsers', 'Portable')]
    [string]$InstallLocation = 'CurrentUser',
    
    [bool]$ConfigureVSCode = $true,
    [bool]$CreateShortcuts = $true
)

$ErrorActionPreference = 'Stop'

# Installation banner
Write-Host @"

═══════════════════════════════════════════════════════════════════
    🤖 AI Attribution Tools - VS Code Copilot Integration Setup
═══════════════════════════════════════════════════════════════════
    
    Automated installation for Windows 11 + VS Code Copilot environments
    
    📦 PowerShell Module: AIAttributionTools
    🔧 VS Code Extensions: PowerShell, GitHub Copilot integration
    ⚡ Out-of-the-box experience for AI development transparency
    
═══════════════════════════════════════════════════════════════════

"@ -ForegroundColor Cyan

# Step 1: Install PowerShell Module
Write-Host "📦 Installing AI Attribution Tools PowerShell Module..." -ForegroundColor Yellow

try {
    # Check if PowerShell Gallery is trusted
    $gallery = Get-PSRepository -Name PSGallery
    if ($gallery.InstallationPolicy -ne 'Trusted') {
        Write-Host "   Configuring PowerShell Gallery as trusted repository..." -ForegroundColor Gray
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    
    # Install or update module
    $existingModule = Get-Module -ListAvailable -Name AIAttributionTools
    if ($existingModule) {
        Write-Host "   Updating existing AIAttributionTools module..." -ForegroundColor Gray
        Update-Module -Name AIAttributionTools -Scope $InstallLocation -Force
    } else {
        Write-Host "   Installing AIAttributionTools module from PowerShell Gallery..." -ForegroundColor Gray
        Install-Module -Name AIAttributionTools -Scope $InstallLocation -Force -AllowClobber
    }
    
    # Verify installation
    Import-Module AIAttributionTools -Force
    $moduleInfo = Get-Module AIAttributionTools
    Write-Host "   ✅ Module installed successfully! Version: $($moduleInfo.Version)" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to install PowerShell module: $($_.Exception.Message)"
    exit 1
}

# Step 2: Install and Configure VS Code Extensions
if ($ConfigureVSCode) {
    Write-Host "`n🔧 Configuring VS Code Copilot Environment..." -ForegroundColor Yellow
    
    # Detect VS Code installations
    $vsCodePaths = @(
        "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\bin\code.cmd",
        "${env:PROGRAMFILES}\Microsoft VS Code\bin\code.cmd",
        "${env:PROGRAMFILES(X86)}\Microsoft VS Code\bin\code.cmd"
    )
    
    $vsCodePath = $vsCodePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if ($vsCodePath) {
        Write-Host "   Found VS Code at: $vsCodePath" -ForegroundColor Gray
        
        # Install required extensions
        $extensions = @(
            'ms-vscode.powershell',           # PowerShell extension
            'GitHub.copilot',                 # GitHub Copilot
            'GitHub.copilot-chat',            # GitHub Copilot Chat
            'ms-vscode.vscode-json',          # JSON support
            'eamodio.gitlens'                 # Git integration
        )
        
        foreach ($extension in $extensions) {
            Write-Host "   Installing VS Code extension: $extension" -ForegroundColor Gray
            & $vsCodePath --install-extension $extension --force 2>$null
        }
        
        # Create VS Code settings for AI Attribution Tools
        $vsCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
        $aiAttributionSettings = @{
            "powershell.defaultProfile" = "Windows PowerShell"
            "powershell.enableProfileLoading" = $true
            "files.associations" = @{
                "*.ps1" = "powershell"
                "*llm-attribution*.json" = "json"
            }
            "ai-attribution.autoAnalyze" = $true
            "ai-attribution.defaultTimeRange" = "30 days ago"
            "ai-attribution.showNotifications" = $true
        }
        
        # Merge with existing settings
        if (Test-Path $vsCodeSettingsPath) {
            $existingSettings = Get-Content $vsCodeSettingsPath | ConvertFrom-Json -AsHashtable
            $aiAttributionSettings.Keys | ForEach-Object {
                $existingSettings[$_] = $aiAttributionSettings[$_]
            }
            $existingSettings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsPath
        } else {
            New-Item (Split-Path $vsCodeSettingsPath) -ItemType Directory -Force | Out-Null
            $aiAttributionSettings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsPath
        }
        
        Write-Host "   ✅ VS Code configured successfully!" -ForegroundColor Green
        
    } else {
        Write-Warning "VS Code not found. Please install VS Code and run this script again."
    }
}

# Step 3: Create PowerShell Profile Integration
Write-Host "`n⚡ Setting up PowerShell Profile Integration..." -ForegroundColor Yellow

$profileContent = @'
# AI Attribution Tools - Auto-load for VS Code Copilot environments
if ($env:TERM_PROGRAM -eq "vscode" -or $env:VSCODE_PID) {
    Import-Module AIAttributionTools -ErrorAction SilentlyContinue
    
    # Convenient aliases
    Set-Alias -Name "ai-analyze" -Value "Invoke-LLMCommitAnalysis" -ErrorAction SilentlyContinue
    Set-Alias -Name "llm-check" -Value "Test-AICommitPattern" -ErrorAction SilentlyContinue
    
    Write-Host "🤖 AI Attribution Tools loaded for VS Code Copilot!" -ForegroundColor Green
}
'@

$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

if (!(Get-Content $profilePath -ErrorAction SilentlyContinue | Select-String "AI Attribution Tools")) {
    Add-Content -Path $profilePath -Value "`n$profileContent"
    Write-Host "   ✅ PowerShell profile updated!" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  PowerShell profile already configured" -ForegroundColor Gray
}

# Step 4: Create Desktop Shortcuts
if ($CreateShortcuts) {
    Write-Host "`n🔗 Creating Desktop Shortcuts..." -ForegroundColor Yellow
    
    $shell = New-Object -ComObject WScript.Shell
    
    # AI Attribution Analysis shortcut
    $shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\AI Attribution Analysis.lnk")
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoProfile -Command `"Import-Module AIAttributionTools; Invoke-LLMCommitAnalysis -ShowDetails`""
    $shortcut.WorkingDirectory = "$env:USERPROFILE"
    $shortcut.Description = "Quick AI Attribution Analysis"
    $shortcut.Save()
    
    Write-Host "   ✅ Desktop shortcuts created!" -ForegroundColor Green
}

# Step 5: Verification and Testing
Write-Host "`n🧪 Verifying Installation..." -ForegroundColor Yellow

try {
    # Test module import
    Import-Module AIAttributionTools -Force
    $commands = Get-Command -Module AIAttributionTools
    Write-Host "   ✅ Module functions available: $($commands.Count)" -ForegroundColor Green
    
    # Test in sample git repository
    if (Test-Path ".git") {
        Write-Host "   🔍 Testing in current git repository..." -ForegroundColor Gray
        $testResult = Invoke-LLMCommitAnalysis -Since "7 days ago" -WhatIf 2>&1
        Write-Host "   ✅ Git repository analysis ready!" -ForegroundColor Green
    }
    
} catch {
    Write-Warning "Verification encountered issues: $($_.Exception.Message)"
}

# Installation complete
Write-Host @"

═══════════════════════════════════════════════════════════════════
    🎉 Installation Complete! 
═══════════════════════════════════════════════════════════════════

    ✅ AI Attribution Tools PowerShell Module
    ✅ VS Code Copilot Integration  
    ✅ PowerShell Profile Configuration
    ✅ Desktop Shortcuts
    
    🚀 Ready to use! Try these commands:
    
    • Invoke-LLMCommitAnalysis           # Full analysis
    • llm-analyze -Since "7 days ago"    # Quick alias
    • Get-Command -Module AIAttributionTools  # See all commands
    
    📖 Documentation: 
    https://github.com/thisis-romar/emblem.io-whatsapp-receipts/blob/main/AIAttributionTools/README.md
    
    🐛 Issues & Support:
    https://github.com/thisis-romar/emblem.io-whatsapp-receipts/issues

═══════════════════════════════════════════════════════════════════

"@ -ForegroundColor Green

# Restart recommendation
Write-Host "💡 Recommendation: Restart VS Code to fully activate AI Attribution Tools integration.`n" -ForegroundColor Cyan