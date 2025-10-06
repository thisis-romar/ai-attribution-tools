# LLM Commit Identifier Tool - WhatsApp Receipts Project
# Identifies and attributes git commits to specific AI/LLM models
# Tracks AI assistance in development workflow

param(
    [Parameter(Mandatory = $false)]
    [string]$Since = "4 weeks ago",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "llm-attribution-analysis.json",
    
    [Parameter(Mandatory = $false)]
    [switch]$ShowDetails,
    
    [Parameter(Mandatory = $false)]
    [switch]$SetAIAuthor,
    
    [Parameter(Mandatory = $false)]
    [string]$LLMModel = "Claude AI (copilot/claude-sonnet-4)"
)

# Function to detect AI-assisted commits based on patterns
function Detect-AIAssistedCommits {
    param([array]$Commits)
    
    $aiPatterns = @(
        # Common AI-generated commit message patterns
        "feat:", "fix:", "docs:", "style:", "refactor:", "test:", "chore:",
        "Add comprehensive", "Implement", "Update", "Create", "Enhance",
        "Initial commit", "Setup", "Configure", "Integrate",
        # File patterns that suggest AI assistance
        "copilot", "claude", "ai", "llm", "assistant",
        # Code quality indicators
        "eslint", "prettier", "typescript", "documentation"
    )
    
    $aiIndicators = @{
        "High Probability"   = @(
            "comprehensive", "implementation", "integration", 
            "sophisticated", "systematic", "optimization"
        )
        "Medium Probability" = @(
            "setup", "configure", "enhance", "update", "create"
        )
        "AI Tools Mentioned" = @(
            "copilot", "claude", "ai", "assistant", "llm"
        )
    }
    
    $analysisResults = @()
    
    foreach ($commit in $Commits) {
        $aiScore = 0
        $indicators = @()
        $commitText = "$($commit.message) $($commit.author)".ToLower()
        
        # Check for AI indicators
        foreach ($category in $aiIndicators.Keys) {
            foreach ($indicator in $aiIndicators[$category]) {
                if ($commitText -match $indicator) {
                    switch ($category) {
                        "High Probability" { $aiScore += 3 }
                        "Medium Probability" { $aiScore += 2 }  
                        "AI Tools Mentioned" { $aiScore += 5 }
                    }
                    $indicators += "$category`: $indicator"
                }
            }
        }
        
        # Check for conventional commit patterns (often AI-generated)
        if ($commit.message -match "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+") {
            $aiScore += 2
            $indicators += "Conventional Commit Format"
        }
        
        # Check for comprehensive/detailed commit messages (AI tendency)
        if ($commit.message.Length -gt 50) {
            $aiScore += 1
            $indicators += "Detailed Commit Message"
        }
        
        # Determine AI likelihood
        $aiLikelihood = switch ($aiScore) {
            { $_ -ge 5 } { "Very High" }
            { $_ -ge 3 } { "High" }  
            { $_ -ge 1 } { "Medium" }
            default { "Low" }
        }
        
        $analysisResults += @{
            Hash         = $commit.hash
            ShortHash    = $commit.short
            Message      = $commit.message
            Author       = $commit.author
            Date         = $commit.date
            AIScore      = $aiScore
            AILikelihood = $aiLikelihood
            Indicators   = $indicators
            PossibleLLM  = if ($aiScore -ge 3) { "Claude AI / GitHub Copilot" } else { "Human" }
        }
    }
    
    return $analysisResults
}

# Function to get enhanced git commit history with LLM detection
function Get-LLMAttributedCommits {
    if (-not (Test-Path ".git")) {
        Write-Warning "Not in a git repository"
        return @()
    }
    
    try {
        $gitCommand = "git log --since=`"$Since`" --pretty=format:'{`"hash`":`"%H`",`"short`":`"%h`",`"message`":`"%s`",`"author`":`"%an`",`"email`":`"%ae`",`"date`":`"%ad`",`"dateRel`":`"%ar`"}' --date=iso"
        
        if ($ShowDetails) {
            Write-Host "Executing: $gitCommand" -ForegroundColor Gray
        }
        
        $commits = Invoke-Expression $gitCommand
        $commitObjects = @()
        
        foreach ($commit in $commits) {
            if ($commit.Trim()) {
                try {
                    $commitObj = $commit | ConvertFrom-Json
                    $commitObjects += $commitObj
                }
                catch {
                    if ($ShowDetails) {
                        Write-Warning "Could not parse commit: $commit"
                    }
                }
            }
        }
        
        return $commitObjects
    }
    catch {
        Write-Warning "Could not retrieve git history: $($_.Exception.Message)"
        return @()
    }
}

# Function to update git author for AI-assisted commits
function Set-AICommitAuthor {
    param(
        [string]$CommitHash,
        [string]$LLMModel
    )
    
    try {
        # This would rewrite history - use with caution
        Write-Host "Setting AI author for commit $CommitHash to $LLMModel" -ForegroundColor Yellow
        
        # For demonstration - actual implementation would use git filter-branch or git rebase
        Write-Host "Command would be: git commit --amend --author=`"$LLMModel <ai@assistant.local>`"" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Warning "Could not update commit author: $($_.Exception.Message)"
        return $false
    }
}

# Function to generate LLM attribution report
function Generate-LLMReport {
    param([array]$AnalysisResults)
    
    $stats = @{
        TotalCommits      = $AnalysisResults.Count
        AIAssistedCommits = ($AnalysisResults | Where-Object { $_.AILikelihood -in @("High", "Very High") }).Count
        PossibleAICommits = ($AnalysisResults | Where-Object { $_.AILikelihood -eq "Medium" }).Count
        HumanCommits      = ($AnalysisResults | Where-Object { $_.AILikelihood -eq "Low" }).Count
        AIPercentage      = 0
    }
    
    if ($stats.TotalCommits -gt 0) {
        $stats.AIPercentage = [math]::Round(($stats.AIAssistedCommits / $stats.TotalCommits) * 100, 2)
    }
    
    $topAICommits = $AnalysisResults | 
    Where-Object { $_.AILikelihood -in @("High", "Very High") } |
    Sort-Object AIScore -Descending |
    Select-Object -First 10
    
    return @{
        Statistics      = $stats
        TopAICommits    = $topAICommits
        AllCommits      = $AnalysisResults
        Recommendations = @(
            "Consider using consistent AI attribution in commit authors",
            "Track AI model versions used for development history",
            "Document AI assistance patterns for workflow optimization"
        )
    }
}

# Main execution
Write-Host "=== LLM Commit Identifier & Attribution Tool ===" -ForegroundColor Green
Write-Host "Analyzing commits since: $Since" -ForegroundColor Cyan

# Get git commits
Write-Host "Retrieving git commit history..." -ForegroundColor Yellow
$commits = Get-LLMAttributedCommits

if ($commits.Count -eq 0) {
    Write-Warning "No commits found in the specified time range"
    exit 1
}

Write-Host "Found $($commits.Count) commits to analyze" -ForegroundColor Green

# Detect AI-assisted commits
Write-Host "Analyzing commits for AI assistance patterns..." -ForegroundColor Yellow
$analysis = Detect-AIAssistedCommits -Commits $commits

# Generate report
$report = Generate-LLMReport -AnalysisResults $analysis

# Create output
$output = @{
    GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ProjectPath = (Get-Location).Path
    TimeRange   = $Since
    Report      = $report
    Tools       = @{
        LLMIdentifier = "LLMCommitIdentifier.ps1"
        Version       = "1.0"
        Project       = "WhatsApp Receipts Processing System"
    }
}

# Save results
try {
    $output | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "LLM attribution analysis saved to: $OutputPath" -ForegroundColor Green
}
catch {
    Write-Error "Could not save output: $($_.Exception.Message)"
    exit 1
}

# Display summary
Write-Host "`n=== LLM ATTRIBUTION ANALYSIS ===" -ForegroundColor Green
Write-Host "Total Commits Analyzed: $($report.Statistics.TotalCommits)" -ForegroundColor White
Write-Host "AI-Assisted Commits (High/Very High): $($report.Statistics.AIAssistedCommits)" -ForegroundColor Cyan
Write-Host "Possible AI Commits (Medium): $($report.Statistics.PossibleAICommits)" -ForegroundColor Yellow
Write-Host "Human Commits (Low): $($report.Statistics.HumanCommits)" -ForegroundColor White
Write-Host "AI Assistance Percentage: $($report.Statistics.AIPercentage)%" -ForegroundColor Magenta

if ($report.TopAICommits.Count -gt 0) {
    Write-Host "`nTop AI-Assisted Commits:" -ForegroundColor Yellow
    foreach ($commit in $report.TopAICommits | Select-Object -First 5) {
        Write-Host "  $($commit.ShortHash) - $($commit.AILikelihood) ($($commit.AIScore) pts) - $($commit.Message.Substring(0, [Math]::Min(60, $commit.Message.Length)))..." -ForegroundColor Gray
    }
}

if ($SetAIAuthor -and $report.TopAICommits.Count -gt 0) {
    Write-Host "`nAI Author Attribution (Demo Mode):" -ForegroundColor Red
    Write-Host "Use with caution - this would rewrite git history!" -ForegroundColor Red
    
    foreach ($commit in $report.TopAICommits | Select-Object -First 3) {
        Set-AICommitAuthor -CommitHash $commit.Hash -LLMModel $LLMModel
    }
}

Write-Host "`nLLM commit analysis complete!" -ForegroundColor Green
Write-Host "Use -SetAIAuthor to update commit authors (rewrites history!)" -ForegroundColor Yellow