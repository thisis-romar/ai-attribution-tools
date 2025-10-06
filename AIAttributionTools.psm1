# AI Attribution Tools PowerShell Module
# Advanced AI-assisted commit detection and attribution management

#Requires -Version 5.1

# Import helper functions
$ModuleRoot = $PSScriptRoot
$Private = Join-Path $ModuleRoot 'Private'
$Public = Join-Path $ModuleRoot 'Public'

# Import private functions first
if (Test-Path $Private) {
    Get-ChildItem -Path $Private -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

# Import public functions
if (Test-Path $Public) {
    Get-ChildItem -Path $Public -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

# Module variables
$ModuleVersion = (Import-PowerShellDataFile -Path (Join-Path $ModuleRoot 'AIAttributionTools.psd1')).ModuleVersion
$script:AIAttributionConfig = @{
    Version = $ModuleVersion
    LastUpdated = Get-Date
    SupportedAIModels = @(
        'Claude AI', 'ChatGPT', 'GitHub Copilot', 'Cursor AI', 'Tabnine',
        'CodeWhisperer', 'IntelliCode', 'Codeium', 'Sourcegraph Cody'
    )
    ScorePrecision = 0.1
    MaxScore = 11
    DefaultTimeRange = '30 days'
}

# Export module information
# Validate that core functions were loaded successfully
$coreRequiredFunctions = @('Test-AICommitPattern', 'Get-CommitHistory', 'Export-AnalysisReport', 'Update-CommitAttribution')
$loadErrors = @()

foreach ($funcName in $coreRequiredFunctions) {
    if (-not (Get-Command -Name $funcName -ErrorAction SilentlyContinue)) {
        $loadErrors += "Missing core function: $funcName"
    }
}

if ($loadErrors.Count -gt 0) {
    Write-Warning "Module load issues detected:"
    $loadErrors | ForEach-Object { Write-Warning "  - $_" }
    Write-Warning "Some functionality may be limited. Check Private function files."
}

# Export module functions and aliases
Export-ModuleMember -Function @(
    'Invoke-LLMCommitAnalysis'
) -Alias @(
    'llm-analyze',
    'ai-commits', 
    'ai-attr'
) -Variable @(
    'AIAttributionConfig'
)

# Display module load message
Write-Host "AI Attribution Tools v$ModuleVersion loaded successfully!" -ForegroundColor Green
Write-Host "Use 'Get-Command -Module AIAttributionTools' to see available commands" -ForegroundColor Cyan