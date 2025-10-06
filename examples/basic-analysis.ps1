# Basic AI Attribution Analysis Example
# This script demonstrates basic usage of AIAttributionTools

# Install the module if not already installed
if (-not (Get-Module -ListAvailable -Name AIAttributionTools)) {
    Write-Host "Installing AIAttributionTools module..." -ForegroundColor Green
    Install-Module -Name AIAttributionTools -Scope CurrentUser -Force
}

# Import the module
Write-Host "Importing AIAttributionTools..." -ForegroundColor Green
Import-Module AIAttributionTools

# Basic analysis of last 30 days
Write-Host "`nRunning basic analysis of last 30 days..." -ForegroundColor Cyan
$basicAnalysis = Invoke-LLMCommitAnalysis

# Display summary
Write-Host "`n=== AI Attribution Analysis Results ===" -ForegroundColor Yellow
Write-Host "Total Commits Analyzed: $($basicAnalysis.TotalCommits)" -ForegroundColor White
Write-Host "AI-Likely Commits: $($basicAnalysis.AILikelyCommits)" -ForegroundColor White
Write-Host "AI Usage Percentage: $($basicAnalysis.AIPercentage)%" -ForegroundColor White
Write-Host "Average AI Score: $($basicAnalysis.AverageScore)" -ForegroundColor White
Write-Host "Highest Score Found: $($basicAnalysis.HighestScore)" -ForegroundColor White

# Provide interpretation
if ($basicAnalysis.AIPercentage -gt 30) {
    Write-Host "`nInterpretation: High AI usage detected in this repository." -ForegroundColor Red
} elseif ($basicAnalysis.AIPercentage -gt 10) {
    Write-Host "`nInterpretation: Moderate AI usage detected." -ForegroundColor Yellow
} else {
    Write-Host "`nInterpretation: Low AI usage detected." -ForegroundColor Green
}

Write-Host "`nFor detailed analysis, run: Invoke-LLMCommitAnalysis -ShowDetails" -ForegroundColor Cyan