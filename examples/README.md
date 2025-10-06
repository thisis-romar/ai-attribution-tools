# 🚀 AI Attribution Tools - Usage Examples

This directory contains practical examples of using AIAttributionTools in various scenarios.

---

## 📁 **Example Files**

### **Basic Usage**
- [basic-analysis.ps1](basic-analysis.ps1) - Simple commit analysis
- [detailed-report.ps1](detailed-report.ps1) - Comprehensive reporting

### **Advanced Scenarios**
- [multi-repo-analysis.ps1](multi-repo-analysis.ps1) - Analyze multiple repositories
- [ci-cd-integration.ps1](ci-cd-integration.ps1) - CI/CD pipeline integration
- [team-dashboard.ps1](team-dashboard.ps1) - Team productivity dashboard

### **Automation Scripts**
- [git-hook-example.ps1](git-hook-example.ps1) - Git hook implementation
- [scheduled-analysis.ps1](scheduled-analysis.ps1) - Automated periodic analysis
- [export-reports.ps1](export-reports.ps1) - Data export utilities

---

## 🎯 **Quick Examples**

### **Basic Analysis**
```powershell
# Install and run basic analysis
Install-Module -Name AIAttributionTools -Scope CurrentUser
Import-Module AIAttributionTools
Invoke-LLMCommitAnalysis
```

### **Detailed Team Report**
```powershell
# Generate detailed team report
$analysis = Invoke-LLMCommitAnalysis -Since "30 days ago" -ShowDetails
Write-Host "Team AI Usage: $($analysis.AIPercentage)%"
$analysis.Analysis | Where-Object { $_.Score -gt 6 } | Format-Table Commit, Score, Author
```

### **Export to CSV**
```powershell
# Export results for external analysis
$results = Invoke-LLMCommitAnalysis -ShowDetails
$results.Analysis | Export-Csv "ai-commits-analysis.csv" -NoTypeInformation
Write-Host "Results exported to ai-commits-analysis.csv"
```

---

## 📊 **Integration Examples**

### **GitHub Actions**
```yaml
name: AI Attribution Analysis
on: [push, pull_request]
jobs:
  ai-analysis:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    - name: Analyze AI Usage
      shell: pwsh
      run: |
        Install-Module AIAttributionTools -Force -Scope CurrentUser
        $analysis = Invoke-LLMCommitAnalysis -Since "1 day ago"
        Write-Host "AI Usage: $($analysis.AIPercentage)%"
```

### **Azure DevOps**
```yaml
steps:
- task: PowerShell@2
  displayName: 'AI Attribution Analysis'
  inputs:
    targetType: 'inline'
    script: |
      Install-Module AIAttributionTools -Force -Scope CurrentUser
      Invoke-LLMCommitAnalysis -ShowDetails
```

---

## 🛠️ **Automation Scripts**

### **Weekly Team Report**
```powershell
# Schedule this script to run weekly
$analysis = Invoke-LLMCommitAnalysis -Since "7 days ago" -ShowDetails
$report = @{
    Period = "Week of $(Get-Date -Format 'yyyy-MM-dd')"
    TotalCommits = $analysis.TotalCommits
    AIPercentage = $analysis.AIPercentage
    TopAICommits = $analysis.Analysis | Sort-Object Score -Descending | Select-Object -First 5
}
$report | ConvertTo-Json -Depth 3 | Out-File "weekly-ai-report.json"
```

---

## 📚 **See Also**

- [API Reference](../docs/API.md)
- [Configuration Guide](../docs/Configuration.md)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/AIAttributionTools)

---

**Want to contribute examples?** Submit a PR to our [GitHub repository](https://github.com/thisis-romar/emblem.io-whatsapp-receipts)!