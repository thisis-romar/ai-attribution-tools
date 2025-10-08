# GitHub Actions Integration Example for AI Attribution Tools
# This script demonstrates how to integrate AI Attribution Analysis into CI/CD pipelines

param(
    [string]$Since = "1 day ago",
    [switch]$ShowDetails,
    [string]$Repository = ".",
    [int]$MinimumThreshold = 25
)

Write-Host "🤖 AI Attribution Analysis - CI/CD Integration" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

try {
    # Install AI Attribution Tools if not already available
    if (-not (Get-Module -Name AIAttributionTools -ListAvailable)) {
        Write-Host "📦 Installing AI Attribution Tools..." -ForegroundColor Yellow
        Install-Module -Name AIAttributionTools -Force -Scope CurrentUser -AllowClobber
    }

    # Import the module
    Import-Module AIAttributionTools -Force

    # Run the analysis
    Write-Host "🔍 Analyzing repository commits since: $Since" -ForegroundColor Green
    
    $analysisParams = @{
        Repository = $Repository
        Since = $Since
    }
    
    if ($ShowDetails) {
        $analysisParams.ShowDetails = $true
    }

    $analysis = Invoke-LLMCommitAnalysis @analysisParams

    # Display results
    Write-Host "`n📊 Analysis Results:" -ForegroundColor Cyan
    Write-Host "Total Commits: $($analysis.TotalCommits)" -ForegroundColor White
    Write-Host "AI-Likely Commits: $($analysis.AILikelyCommits)" -ForegroundColor White
    Write-Host "AI Usage Percentage: $($analysis.AIPercentage)%" -ForegroundColor White
    Write-Host "Average AI Score: $($analysis.AverageScore)" -ForegroundColor White

    # Check against threshold
    if ($analysis.AIPercentage -gt $MinimumThreshold) {
        Write-Host "✅ AI usage ($($analysis.AIPercentage)%) exceeds minimum threshold ($MinimumThreshold%)" -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host "⚠️  AI usage ($($analysis.AIPercentage)%) below minimum threshold ($MinimumThreshold%)" -ForegroundColor Yellow
        $exitCode = 0  # Don't fail the build, just warn
    }

    # Export results for further processing
    $resultsPath = "ai-attribution-results.json"
    $analysis | ConvertTo-Json -Depth 3 | Out-File -FilePath $resultsPath -Encoding UTF8
    Write-Host "📄 Results exported to: $resultsPath" -ForegroundColor Green

    # Set GitHub Actions output if running in CI
    if ($env:GITHUB_ACTIONS -eq "true") {
        Write-Host "Setting GitHub Actions outputs..." -ForegroundColor Yellow
        
        # Set outputs for use in other steps
        "ai-percentage=$($analysis.AIPercentage)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
        "total-commits=$($analysis.TotalCommits)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
        "ai-commits=$($analysis.AILikelyCommits)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
        "average-score=$($analysis.AverageScore)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
        
        # Create job summary
        $summary = @"
## 🤖 AI Attribution Analysis Results

| Metric | Value |
|--------|-------|
| **Total Commits** | $($analysis.TotalCommits) |
| **AI-Likely Commits** | $($analysis.AILikelyCommits) |
| **AI Usage Percentage** | $($analysis.AIPercentage)% |
| **Average AI Score** | $($analysis.AverageScore) |

### Analysis Period
- **Since**: $Since
- **Repository**: $Repository
- **Threshold**: $MinimumThreshold%

### Status
$(if ($analysis.AIPercentage -gt $MinimumThreshold) { "✅ **PASSED** - AI usage meets requirements" } else { "⚠️ **WARNING** - AI usage below threshold" })
"@

        $summary | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding UTF8
    }

    exit $exitCode

} catch {
    Write-Host "❌ Error during AI attribution analysis:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    if ($env:GITHUB_ACTIONS -eq "true") {
        # Set failed status in GitHub Actions
        "error=AI attribution analysis failed: $($_.Exception.Message)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding UTF8
    }
    
    exit 1
}

# Example GitHub Actions Workflow
<#
# .github/workflows/ai-attribution-analysis.yml

name: AI Attribution Analysis
on: 
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  ai-analysis:
    name: Analyze AI Usage
    runs-on: windows-latest
    permissions:
      contents: read
      pull-requests: write  # For PR comments
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Full history for accurate analysis
    
    - name: Run AI Attribution Analysis
      shell: pwsh
      run: |
        .\examples\ci-cd-integration.ps1 -Since "7 days ago" -ShowDetails -MinimumThreshold 20
      
    - name: Upload results artifact
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: ai-attribution-results
        path: ai-attribution-results.json
        retention-days: 30
    
    - name: Comment on PR
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          try {
            const results = JSON.parse(fs.readFileSync('ai-attribution-results.json', 'utf8'));
            const comment = `## 🤖 AI Attribution Analysis
            
            | Metric | Value |
            |--------|-------|
            | **AI Usage** | ${results.AIPercentage}% |
            | **Total Commits** | ${results.TotalCommits} |
            | **AI-Likely Commits** | ${results.AILikelyCommits} |
            
            Analysis covers the last 7 days of development activity.`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
          } catch (error) {
            console.log('Could not post PR comment:', error.message);
          }

#>