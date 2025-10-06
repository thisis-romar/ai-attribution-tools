function Invoke-LLMCommitAnalysis {
    <#
    .SYNOPSIS
    Advanced AI-assisted commit detection and analysis for GitHub repositories.
    
    .DESCRIPTION
    Analyzes git commit history to identify AI-assisted commits using sophisticated pattern 
    detection algorithms. Provides comprehensive scoring (0-11+ scale) and statistical 
    reporting for AI development transparency and compliance.
    
    .PARAMETER Since  
    Time range for commit analysis. Supports formats like "7 days ago", "2 weeks ago", "1 month ago".
    Default: "30 days ago"
    
    .PARAMETER OutputPath
    Path to save analysis results in JSON format.
    Default: "llm-attribution-analysis.json"
    
    .PARAMETER ShowDetails
    Display detailed processing information and intermediate results.
    
    .PARAMETER SetAIAuthor
    Enable AI commit author attribution (WARNING: Rewrites git history).
    
    .PARAMETER LLMModel
    Specify the AI model name for attribution.
    Default: "AI Assistant"
    
    .EXAMPLE
    Invoke-LLMCommitAnalysis
    # Basic analysis of last 30 days with default settings
    
    .EXAMPLE  
    Invoke-LLMCommitAnalysis -Since "7 days ago" -ShowDetails
    # Detailed analysis of last 7 days with verbose output
    
    .EXAMPLE
    Invoke-LLMCommitAnalysis -OutputPath "custom-analysis.json" -LLMModel "Claude AI"
    # Custom output path with specific AI model attribution
    
    .NOTES
    Version: 1.0.0
    Author: Emblem.iO Team
    Requires: PowerShell 5.1+, Git repository
    
    .LINK
    https://github.com/thisis-romar/emblem.io-whatsapp-receipts/blob/main/AIAttributionTools/README.md
    #>
    
    [CmdletBinding()]
    param(
        [string]$Since = "30 days ago",
        [string]$OutputPath = "llm-attribution-analysis.json", 
        [switch]$ShowDetails,
        [switch]$SetAIAuthor,
        [string]$LLMModel = "AI Assistant"
    )
    
    try {
        Write-Host "🤖 AI Attribution Analysis Starting..." -ForegroundColor Cyan
        Write-Host "Repository: $(Split-Path -Leaf (Get-Location))" -ForegroundColor Gray
        Write-Host "Time Range: $Since" -ForegroundColor Gray
        Write-Host ""
        
        # Step 1: Get commit history from repository
        Write-Verbose "Retrieving commit history..."
        $commits = Get-CommitHistory -Since $Since
        
        if (-not $commits -or $commits.Count -eq 0) {
            Write-Warning "No commits found in the specified time range: $Since"
            return @{
                TotalCommits = 0
                AICommits = 0
                AnalysisResults = @()
            }
        }
        
        Write-Host "Found $($commits.Count) commits to analyze" -ForegroundColor Green
        
        # Step 2: Perform sophisticated AI pattern analysis
        Write-Verbose "Performing AI pattern analysis..."
        $analysisResults = Test-AICommitPattern -Commits $commits -ShowDetails:$ShowDetails
        
        # Step 3: Filter and categorize results
        $aiCommits = $analysisResults | Where-Object { $_.AIScore -ge 3.0 }
        $highConfidenceCommits = $analysisResults | Where-Object { $_.AIScore -ge 7.0 }
        
        Write-Host "`n✅ Analysis Complete!" -ForegroundColor Green
        Write-Host "AI-Assisted Commits (≥3.0): $($aiCommits.Count)" -ForegroundColor Yellow
        Write-Host "High-Confidence AI (≥7.0): $($highConfidenceCommits.Count)" -ForegroundColor Cyan
        
        # Step 4: Generate reports and save results
        if ($analysisResults.Count -gt 0) {
            # Save JSON results
            $results = @{
                metadata = @{
                    generatedAt = Get-Date -Format "o"
                    repository = Split-Path -Leaf (Get-Location)
                    analysisVersion = "1.0.0"
                    timeRange = $Since
                }
                summary = @{
                    totalCommits = $analysisResults.Count
                    aiAssistedCommits = $aiCommits.Count
                    highConfidenceAI = $highConfidenceCommits.Count
                    aiAssistanceRate = [Math]::Round(($aiCommits.Count / $analysisResults.Count) * 100, 1)
                }
                commits = $analysisResults
            }
            
            $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8
            Write-Host "📄 Results saved: $OutputPath" -ForegroundColor Green
            
            # Generate console report
            Export-AnalysisReport -AnalysisResults $analysisResults -Format Console
            
            # Update commit attribution if requested
            if ($SetAIAuthor -and $aiCommits.Count -gt 0) {
                Write-Host "`n⚠️  AI Attribution Update (REWRITES HISTORY)" -ForegroundColor Red
                $confirmation = Read-Host "Continue with git history rewrite? (y/N)"
                if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
                    Update-CommitAttribution -Commits $aiCommits -AIThreshold 3.0
                }
            }
        }
        
        # Return structured results for programmatic use
        return $results
        
    } catch {
        Write-Error "🚨 LLM analysis failed: $($_.Exception.Message)"
        if ($ShowDetails) {
            Write-Error "Stack trace: $($_.Exception.StackTrace)"
        }
        throw
    }
    
    Write-Host "=== AI Attribution Analysis v$($script:AIAttributionConfig.Version) ===" -ForegroundColor Green
    Write-Host "Analyzing commits since: $Since" -ForegroundColor Cyan
    
    # Validate git repository
    if (-not (Test-Path ".git")) {
        throw "Not in a git repository. Please run this command from the root of a git repository."
    }
    
    try {
        # Get git commits using enhanced detection
        $commits = Get-AIAttributedCommits -Since $Since -ShowDetails:$ShowDetails
        
        if ($commits.Count -eq 0) {
            Write-Warning "No commits found in the specified time range: $Since"
            return $null
        }
        
        Write-Host "Found $($commits.Count) commits to analyze" -ForegroundColor Green
        
        # Perform AI pattern detection
        $analysis = Test-AICommitPattern -Commits $commits -ShowDetails:$ShowDetails
        
        # Generate comprehensive report
        $report = New-LLMReport -AnalysisResults $analysis
        
        # Create output structure
        $output = @{
            GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ModuleVersion = $script:AIAttributionConfig.Version
            ProjectPath = (Get-Location).Path
            TimeRange = $Since
            Report = $report
            Metadata = @{
                Tool = "AI Attribution Tools"
                LLMIdentifier = "Invoke-LLMCommitAnalysis"
                SupportedModels = $script:AIAttributionConfig.SupportedAIModels
                ScorePrecision = $script:AIAttributionConfig.ScorePrecision
                MaxScore = $script:AIAttributionConfig.MaxScore
            }
        }
        
        # Save results
        $output | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "Analysis saved to: $OutputPath" -ForegroundColor Green
        
        # Display summary
        Write-Host "`n=== AI ATTRIBUTION ANALYSIS RESULTS ===" -ForegroundColor Green
        Write-Host "Total Commits Analyzed: $($report.Statistics.TotalCommits)" -ForegroundColor White
        Write-Host "AI-Assisted Commits (High/Very High): $($report.Statistics.AIAssistedCommits)" -ForegroundColor Cyan
        Write-Host "Possible AI Commits (Medium): $($report.Statistics.PossibleAICommits)" -ForegroundColor Yellow  
        Write-Host "Human Commits (Low): $($report.Statistics.HumanCommits)" -ForegroundColor White
        Write-Host "AI Assistance Percentage: $($report.Statistics.AIPercentage)%" -ForegroundColor Magenta
        
        # Show top AI commits
        if ($report.TopAICommits.Count -gt 0) {
            Write-Host "`nTop AI-Assisted Commits:" -ForegroundColor Yellow
            foreach ($commit in $report.TopAICommits | Select-Object -First 5) {
                $shortMsg = $commit.Message.Substring(0, [Math]::Min(60, $commit.Message.Length))
                Write-Host "  $($commit.ShortHash) - $($commit.AILikelihood) ($($commit.AIScore) pts) - $shortMsg..." -ForegroundColor Gray
            }
        }
        
        # AI author attribution (if requested)
        if ($SetAIAuthor -and $report.TopAICommits.Count -gt 0) {
            Write-Host "`nAI Author Attribution (CAUTION: Rewrites History):" -ForegroundColor Red
            Write-Host "This operation will modify git history!" -ForegroundColor Red
            
            foreach ($commit in $report.TopAICommits | Select-Object -First 3) {
                Set-AICommitAuthor -CommitHash $commit.Hash -LLMModel $LLMModel
            }
        }
        
        Write-Host "`nAnalysis complete! Use -SetAIAuthor to update commit authors (rewrites history!)" -ForegroundColor Yellow
        
        return $output
        
    } catch {
        Write-Error "Analysis failed: $($_.Exception.Message)"
        throw
    }
}

# Create aliases for convenience
New-Alias -Name "llm-analyze" -Value "Invoke-LLMCommitAnalysis" -Force
New-Alias -Name "ai-commits" -Value "Invoke-LLMCommitAnalysis" -Force