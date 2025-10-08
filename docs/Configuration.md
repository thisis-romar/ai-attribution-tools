# 🛠️ AI Attribution Tools - Configuration Guide

This guide covers advanced configuration options and customization for the AIAttributionTools PowerShell module.

---

## 📋 **Quick Start Configuration**

### **Basic Setup**
```powershell
# Install and import
Install-Module -Name AIAttributionTools -Scope CurrentUser
Import-Module AIAttributionTools

# Basic configuration check
Get-Module AIAttributionTools -ListAvailable
```

---

## ⚙️ **Environment Variables**

### **Core Configuration**
| Variable | Default | Description |
|----------|---------|-------------|
| `AIATTR_DEBUG` | `$false` | Enable detailed debug logging |
| `AIATTR_SCORE_THRESHOLD` | `6` | Minimum score for AI-likely classification |
| `AIATTR_MAX_COMMITS` | `1000` | Maximum commits to analyze per run |
| `AIATTR_CACHE_ENABLED` | `$true` | Enable result caching for performance |

### **Setting Environment Variables**
```powershell
# Enable debug mode
$env:AIATTR_DEBUG = "true"

# Lower detection threshold
$env:AIATTR_SCORE_THRESHOLD = "4"

# Increase analysis limit
$env:AIATTR_MAX_COMMITS = "2000"
```

---

## 🎯 **Detection Sensitivity**

### **Scoring Thresholds**
```powershell
# Conservative detection (higher threshold)
$env:AIATTR_SCORE_THRESHOLD = "8"

# Aggressive detection (lower threshold)
$env:AIATTR_SCORE_THRESHOLD = "3"

# Default detection
$env:AIATTR_SCORE_THRESHOLD = "6"
```

### **Custom Pattern Weights**
Advanced users can modify detection patterns by editing the module configuration:

```powershell
# View current module path
Get-Module AIAttributionTools | Select-Object Path

# Configuration is in Private\Test-AICommitPattern.ps1
```

---

## 📊 **Output Formatting**

### **Detailed vs. Summary Output**
```powershell
# Summary output (default)
Invoke-LLMCommitAnalysis

# Detailed output with individual commit analysis
Invoke-LLMCommitAnalysis -ShowDetails

# Custom formatting
$results = Invoke-LLMCommitAnalysis
$results | ConvertTo-Json -Depth 3 | Out-File "analysis.json"
```

---

## 🔍 **Git Repository Settings**

### **Multi-Repository Analysis**
```powershell
# Analyze multiple repositories
$repos = @("C:\Project1", "C:\Project2", "C:\Project3")
foreach ($repo in $repos) {
    Write-Host "Analyzing: $repo"
    Invoke-LLMCommitAnalysis -Repository $repo -ShowDetails
}
```

### **Remote Repository Analysis**
```powershell
# Clone and analyze remote repository
git clone https://github.com/example/repo.git temp-repo
Invoke-LLMCommitAnalysis -Repository "temp-repo"
Remove-Item "temp-repo" -Recurse -Force
```

---

## ⏱️ **Performance Optimization**

### **Caching Configuration**
```powershell
# Enable caching (default)
$env:AIATTR_CACHE_ENABLED = "true"

# Disable caching for real-time analysis
$env:AIATTR_CACHE_ENABLED = "false"

# Clear cache manually
Remove-Item "$env:TEMP\AIAttributionTools\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### **Large Repository Handling**
```powershell
# Limit analysis scope for large repositories
$env:AIATTR_MAX_COMMITS = "500"

# Use shorter time ranges
Invoke-LLMCommitAnalysis -Since "7 days ago"

# Focus on specific authors
Invoke-LLMCommitAnalysis | Where-Object { $_.Analysis.Author -like "*@mycompany.com" }
```

---

## 🔐 **Security and Privacy**

### **Local Analysis Only**
AIAttributionTools performs **100% local analysis** with:
- ✅ No external API calls
- ✅ No data transmission
- ✅ No cloud dependencies
- ✅ Complete privacy protection

### **Safe Mode Configuration**
```powershell
# Enable additional safety checks
$env:AIATTR_SAFE_MODE = "true"

# Anonymize output (remove author emails)
$env:AIATTR_ANONYMIZE = "true"
```

---

## 📁 **Integration Configurations**

### **VS Code Integration**
```powershell
# Auto-install VS Code integration
& "$env:USERPROFILE\Documents\PowerShell\Modules\AIAttributionTools\Install-AIAttributionTools.ps1"

# Manual VS Code configuration
code --install-extension ms-vscode.powershell
```

### **Git Hooks Integration**
```powershell
# Pre-commit hook setup
$hookPath = ".git\hooks\pre-commit"
@'
#!/bin/sh
pwsh -c "Import-Module AIAttributionTools; Invoke-LLMCommitAnalysis -Since '1 hour ago'"
'@ | Out-File $hookPath -Encoding UTF8
```

### **CI/CD Pipeline Configuration**
```yaml
# GitHub Actions example
- name: AI Attribution Analysis
  shell: pwsh
  run: |
    Install-Module AIAttributionTools -Force -Scope CurrentUser
    $analysis = Invoke-LLMCommitAnalysis -Since "1 day ago"
    if ($analysis.AIPercentage -gt 50) {
        Write-Host "::warning::High AI usage detected: $($analysis.AIPercentage)%"
    }
```

---

## 🛠️ **Troubleshooting Configuration**

### **Common Issues**
```powershell
# Check module installation
Get-Module AIAttributionTools -ListAvailable

# Verify Git availability
git --version

# Test repository access
Test-Path .git

# Check PowerShell version
$PSVersionTable.PSVersion
```

### **Debug Mode**
```powershell
# Enable comprehensive debugging
$env:AIATTR_DEBUG = "true"
$DebugPreference = "Continue"
Invoke-LLMCommitAnalysis -Debug
```

### **Reset to Defaults**
```powershell
# Clear all environment variables
$env:AIATTR_DEBUG = $null
$env:AIATTR_SCORE_THRESHOLD = $null
$env:AIATTR_MAX_COMMITS = $null
$env:AIATTR_CACHE_ENABLED = $null

# Reimport module with defaults
Remove-Module AIAttributionTools -Force
Import-Module AIAttributionTools
```

---

## 📊 **Custom Reporting**

### **Export Formats**
```powershell
$analysis = Invoke-LLMCommitAnalysis -ShowDetails

# JSON export
$analysis | ConvertTo-Json -Depth 5 | Out-File "ai-analysis.json"

# CSV export for Excel
$analysis.Analysis | Export-Csv "ai-commits.csv" -NoTypeInformation

# HTML report
$analysis | ConvertTo-Html | Out-File "ai-report.html"
```

### **Custom Filters**
```powershell
# High-confidence AI commits only
$analysis = Invoke-LLMCommitAnalysis -ShowDetails
$highConfidence = $analysis.Analysis | Where-Object { $_.Score -gt 8 }

# Recent high-activity periods
$recent = Invoke-LLMCommitAnalysis -Since "24 hours ago" -ShowDetails
```

---

## 🔗 **Advanced Integrations**

### **PowerBI Integration**
```powershell
# Export for PowerBI analysis
$data = Invoke-LLMCommitAnalysis -ShowDetails
$data.Analysis | Select-Object Commit, Score, Date, Author | 
    Export-Csv "powerbi-data.csv" -NoTypeInformation
```

### **Slack Notifications**
```powershell
# Weekly AI usage report
$analysis = Invoke-LLMCommitAnalysis -Since "7 days ago"
$message = "Weekly AI Usage: $($analysis.AIPercentage)% of commits"
# Send to Slack webhook (implementation depends on your setup)
```

---

## 📚 **See Also**

- [API Reference](API.md)
- [Usage Examples](../examples/)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/AIAttributionTools)
- [GitHub Repository](https://github.com/thisis-romar/ai-attribution-tools)

---

**Need help with configuration?** Open an issue on our [GitHub repository](https://github.com/thisis-romar/ai-attribution-tools/issues).

