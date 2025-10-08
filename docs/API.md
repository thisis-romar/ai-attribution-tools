# 🤖 AI Attribution Tools - API Reference

This document provides comprehensive API reference for the AIAttributionTools PowerShell module.

---

## 📋 **Table of Contents**

- [Core Functions](#core-functions)
- [Public API](#public-api)
- [Private Functions](#private-functions)
- [Parameters](#parameters)
- [Return Values](#return-values)
- [Examples](#examples)

---

## 🚀 **Core Functions**

### `Invoke-LLMCommitAnalysis`

**Primary function for analyzing Git commits for AI assistance patterns.**

#### **Syntax**
```powershell
Invoke-LLMCommitAnalysis [-Since <String>] [-ShowDetails] [-Repository <String>] [<CommonParameters>]
```

#### **Description**
Analyzes Git commit history to identify patterns indicating AI assistance (GitHub Copilot, ChatGPT, Claude AI, etc.). Uses sophisticated pattern recognition with 0-11+ scoring system.

#### **Parameters**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Since` | String | "30 days ago" | Time range for analysis (e.g., "7 days ago", "2023-01-01") |
| `ShowDetails` | Switch | False | Display detailed analysis for each commit |
| `Repository` | String | Current directory | Path to Git repository to analyze |

#### **Examples**
```powershell
# Basic analysis of last 30 days
Invoke-LLMCommitAnalysis

# Detailed analysis of last week
Invoke-LLMCommitAnalysis -Since "7 days ago" -ShowDetails

# Analyze specific repository
Invoke-LLMCommitAnalysis -Repository "C:\MyProject" -ShowDetails
```

---

## 🔍 **AI Detection Scoring System**

### **Score Ranges**
- **0-2**: Likely human-authored
- **3-5**: Possibly AI-assisted
- **6-8**: Probably AI-assisted
- **9-11+**: Highly likely AI-assisted

### **Detection Patterns**
The tool analyzes multiple factors:

1. **Commit Message Patterns** (0-4 points)
   - Generic messages ("Update code", "Fix bugs")
   - AI-style phrasing and structure
   - Conventional commit format consistency

2. **Code Change Patterns** (0-3 points)
   - Large, comprehensive changes
   - Perfect formatting and structure
   - Multiple file updates in single commit

3. **Timing Patterns** (0-2 points)
   - Rapid commit sequences
   - Consistent timing intervals
   - Off-hours development activity

4. **Author Patterns** (0-2 points)
   - Changes in commit style/quality
   - Sudden productivity increases
   - Technical sophistication jumps

---

## 📊 **Return Values**

### **Analysis Results Object**
```powershell
@{
    TotalCommits = 150
    AILikelyCommits = 23
    AIPercentage = 15.3
    AverageScore = 2.8
    HighestScore = 11
    TimeRange = "30 days ago to now"
    Repository = "C:\MyProject"
    Analysis = @(
        @{
            Commit = "a1b2c3d"
            Message = "Implement advanced data processing pipeline"
            Score = 9
            Reasons = @("Generic message", "Large change", "Perfect formatting")
            Author = "developer@example.com"
            Date = "2023-10-01"
        }
        # ... additional commits
    )
}
```

---

## 🛠️ **Private Functions**

### `Test-AICommitPattern`
Internal function for pattern matching and scoring individual commits.

### `Get-GitRepositoryAnalysis`
Internal function for Git repository inspection and commit retrieval.

---

## ⚙️ **Advanced Configuration**

### **Environment Variables**
- `AIATTR_DEBUG`: Enable debug logging
- `AIATTR_SCORE_THRESHOLD`: Custom scoring threshold (default: 6)
- `AIATTR_MAX_COMMITS`: Maximum commits to analyze (default: 1000)

### **Custom Scoring**
```powershell
# Override default scoring thresholds
$env:AIATTR_SCORE_THRESHOLD = "8"
Invoke-LLMCommitAnalysis -ShowDetails
```

---

## 🔗 **Integration Examples**

### **CI/CD Pipeline Integration**
```powershell
# PowerShell script for build pipeline
$analysis = Invoke-LLMCommitAnalysis -Since "1 day ago"
if ($analysis.AIPercentage -gt 50) {
    Write-Host "High AI usage detected: $($analysis.AIPercentage)%"
}
```

### **Git Hook Integration**
```powershell
# Pre-commit hook
$recentAnalysis = Invoke-LLMCommitAnalysis -Since "1 hour ago"
if ($recentAnalysis.HighestScore -gt 10) {
    Write-Warning "Recent commits show high AI assistance"
}
```

---

## 🆘 **Error Handling**

### **Common Errors**
- **Repository Not Found**: Ensure you're in a Git repository or specify valid path
- **Git Not Available**: Ensure Git is installed and in PATH
- **Access Denied**: Check repository permissions
- **Invalid Date Range**: Use standard Git date formats

### **Error Examples**
```powershell
try {
    $result = Invoke-LLMCommitAnalysis -Repository "invalid/path"
} catch {
    Write-Error "Repository analysis failed: $($_.Exception.Message)"
}
```

---

## 📚 **See Also**

- [Configuration Guide](Configuration.md)
- [Usage Examples](../examples/)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/AIAttributionTools)
- [GitHub Repository](https://github.com/thisis-romar/ai-attribution-tools)

---

**Questions or Issues?** Please report them on our [GitHub Issues](https://github.com/thisis-romar/ai-attribution-tools/issues) page.

