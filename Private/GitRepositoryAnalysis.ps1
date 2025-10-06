# Git Repository Analysis Functions
# Enhanced for module integration and professional use

function Get-CommitHistory {
    <#
    .SYNOPSIS
    Retrieves git commit history with enhanced metadata.
    
    .DESCRIPTION
    Extracts commit information including hash, message, author, and date
    with proper error handling and validation for AI analysis.
    
    .PARAMETER Since
    Time range for commits (default: "30 days ago")
    
    .PARAMETER Repository
    Path to git repository (default: current directory)
    #>
    
    [CmdletBinding()]
    param(
        [string]$Since = "30 days ago",
        [string]$Repository = (Get-Location)
    )
    
    # Validate git repository
    if (-not (Test-Path (Join-Path $Repository ".git"))) {
        throw "Not a git repository: $Repository"
    }
    
    # Change to repository directory
    $currentLocation = Get-Location
    try {
        Set-Location $Repository
        
        # Enhanced git log format with proper escaping
        $gitLogFormat = "%H|%h|%an|%ae|%ad|%s"
        $gitCommand = "git log --since=`"$Since`" --pretty=format:`"$gitLogFormat`" --date=iso-strict"
        
        Write-Verbose "Executing: $gitCommand"
        
        $gitOutput = Invoke-Expression $gitCommand 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            throw "Git log command failed with exit code $LASTEXITCODE"
        }
        
        if (-not $gitOutput) {
            Write-Warning "No commits found since $Since"
            return @()
        }
        
        $commits = @()
        foreach ($line in $gitOutput) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            
            $parts = $line -split '\|', 6
            if ($parts.Length -eq 6) {
                $commits += [PSCustomObject]@{
                    hash    = $parts[0]
                    short   = $parts[1] 
                    author  = $parts[2]
                    email   = $parts[3]
                    date    = $parts[4]
                    message = $parts[5]
                }
            }
        }
        
        Write-Verbose "Retrieved $($commits.Count) commits"
        return $commits
        
    } finally {
        Set-Location $currentLocation
    }
}

function Update-CommitAttribution {
    <#
    .SYNOPSIS
    Updates git commit attribution with AI collaboration information.
    
    .DESCRIPTION
    Safely updates commit authors to reflect AI assistance while
    preserving original commit history and providing dry-run capability.
    
    .PARAMETER Commits
    Array of commits with AI analysis results
    
    .PARAMETER DryRun
    Preview changes without applying them
    
    .PARAMETER AIThreshold
    Minimum AI score to trigger attribution update (default: 5.0)
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Commits,
        
        [switch]$DryRun,
        
        [double]$AIThreshold = 5.0
    )
    
    $updatedCount = 0
    $aiCommits = $Commits | Where-Object { $_.AIScore -ge $AIThreshold }
    
    if (-not $aiCommits) {
        Write-Host "No commits found above AI threshold ($AIThreshold)" -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nAI Attribution Update Summary:" -ForegroundColor Cyan
    Write-Host "Threshold: $AIThreshold" -ForegroundColor Gray
    Write-Host "Commits to update: $($aiCommits.Count)" -ForegroundColor Gray
    
    foreach ($commit in $aiCommits) {
        $newAuthorName = "$($commit.Author) + $($commit.PossibleLLM)"
        
        if ($DryRun) {
            Write-Host "`n[DRY RUN] Would update commit: $($commit.ShortHash)" -ForegroundColor Yellow
            Write-Host "  Current: $($commit.Author)" -ForegroundColor Gray
            Write-Host "  New: $newAuthorName" -ForegroundColor Green  
            Write-Host "  AI Score: $($commit.AIScore) ($($commit.AILikelihood))" -ForegroundColor Cyan
            Write-Host "  Message: $($commit.Message.Substring(0, [Math]::Min(80, $commit.Message.Length)))" -ForegroundColor Gray
        } else {
            try {
                # Use git filter-branch to update author (careful operation)
                $filterCommand = "git filter-branch --env-filter `"
                    if [ `$GIT_COMMIT = '$($commit.Hash)' ]; then
                        export GIT_AUTHOR_NAME='$newAuthorName'
                        export GIT_COMMITTER_NAME='$newAuthorName'
                    fi
                `" --tag-name-filter cat -- --branches --tags"
                
                Write-Host "Updating commit $($commit.ShortHash)..." -ForegroundColor Yellow
                Invoke-Expression $filterCommand
                
                if ($LASTEXITCODE -eq 0) {
                    $updatedCount++
                    Write-Host "  ✓ Updated successfully" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ Failed to update" -ForegroundColor Red
                }
            } catch {
                Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    if (-not $DryRun -and $updatedCount -gt 0) {
        Write-Host "`nSuccessfully updated $updatedCount commits" -ForegroundColor Green
        Write-Host "IMPORTANT: Repository history has been rewritten!" -ForegroundColor Red
        Write-Host "Use 'git push --force-with-lease' to update remote repository" -ForegroundColor Yellow
    }
    
    return $updatedCount
}

function Export-AnalysisReport {
    <#
    .SYNOPSIS
    Generates comprehensive AI attribution analysis report.
    
    .DESCRIPTION
    Creates detailed reports in multiple formats (console, JSON, HTML)
    with statistics, visualizations, and actionable insights.
    
    .PARAMETER AnalysisResults
    Array of commit analysis results
    
    .PARAMETER OutputPath
    Directory for output files (default: current directory)
    
    .PARAMETER Format
    Report formats: Console, JSON, HTML, All (default: Console)
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$AnalysisResults,
        
        [string]$OutputPath = (Get-Location),
        
        [ValidateSet("Console", "JSON", "HTML", "All")]
        [string]$Format = "Console"
    )
    
    if (-not $AnalysisResults -or $AnalysisResults.Count -eq 0) {
        Write-Warning "No analysis results to export"
        return
    }
    
    # Calculate comprehensive statistics
    $stats = @{
        TotalCommits = $AnalysisResults.Count
        AIAssistedCommits = ($AnalysisResults | Where-Object { $_.AIScore -ge 3 }).Count
        AverageAIScore = ($AnalysisResults | Measure-Object -Property AIScore -Average).Average
        MaxAIScore = ($AnalysisResults | Measure-Object -Property AIScore -Maximum).Maximum
        LikelihoodDistribution = ($AnalysisResults | Group-Object -Property AILikelihood | 
            ForEach-Object { @{$_.Name = $_.Count} })
        TopLLMs = ($AnalysisResults | Where-Object { $_.PossibleLLM -ne "Human" } | 
            Group-Object -Property PossibleLLM | Sort-Object Count -Descending | 
            Select-Object -First 3 | ForEach-Object { @{$_.Name = $_.Count} })
        MostActiveAuthors = ($AnalysisResults | Group-Object -Property Author | 
            Sort-Object Count -Descending | Select-Object -First 5)
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    
    # Console Report
    if ($Format -in @("Console", "All")) {
        Write-Host "`n" + "="*80 -ForegroundColor Cyan
        Write-Host "AI ATTRIBUTION ANALYSIS REPORT" -ForegroundColor Cyan
        Write-Host "="*80 -ForegroundColor Cyan
        Write-Host "Generated: $(Get-Date)" -ForegroundColor Gray
        Write-Host "Repository: $(Split-Path -Leaf (Get-Location))" -ForegroundColor Gray
        
        Write-Host "`nOVERALL STATISTICS:" -ForegroundColor Yellow
        Write-Host "  Total Commits Analyzed: $($stats.TotalCommits)" -ForegroundColor White
        Write-Host "  AI-Assisted Commits: $($stats.AIAssistedCommits)" -ForegroundColor White
        Write-Host "  AI Assistance Rate: $([Math]::Round(($stats.AIAssistedCommits / $stats.TotalCommits) * 100, 1))%" -ForegroundColor Green
        Write-Host "  Average AI Score: $([Math]::Round($stats.AverageAIScore, 2))" -ForegroundColor White
        Write-Host "  Highest AI Score: $([Math]::Round($stats.MaxAIScore, 2))" -ForegroundColor White
        
        Write-Host "`nAI LIKELIHOOD DISTRIBUTION:" -ForegroundColor Yellow
        foreach ($item in $stats.LikelihoodDistribution) {
            foreach ($key in $item.Keys) {
                $percentage = [Math]::Round(($item[$key] / $stats.TotalCommits) * 100, 1)
                Write-Host "  $key`: $($item[$key]) commits ($percentage%)" -ForegroundColor White
            }
        }
        
        if ($stats.TopLLMs) {
            Write-Host "`nTOP AI MODELS DETECTED:" -ForegroundColor Yellow
            foreach ($item in $stats.TopLLMs) {
                foreach ($key in $item.Keys) {
                    Write-Host "  $key`: $($item[$key]) commits" -ForegroundColor White
                }
            }
        }
        
        Write-Host "`nHIGH-CONFIDENCE AI COMMITS:" -ForegroundColor Yellow
        $highConfidenceCommits = $AnalysisResults | Where-Object { $_.AIScore -ge 7 } | Sort-Object AIScore -Descending | Select-Object -First 10
        
        foreach ($commit in $highConfidenceCommits) {
            Write-Host "  Score: $($commit.AIScore) | $($commit.ShortHash) | $($commit.PossibleLLM)" -ForegroundColor Cyan
            Write-Host "    $($commit.Message.Substring(0, [Math]::Min(100, $commit.Message.Length)))" -ForegroundColor Gray
        }
    }
    
    # JSON Report
    if ($Format -in @("JSON", "All")) {
        $jsonReport = @{
            metadata = @{
                generatedAt = Get-Date -Format "o"
                repository = Split-Path -Leaf (Get-Location)
                analysisVersion = "1.0.0"
            }
            statistics = $stats
            commits = $AnalysisResults
        }
        
        $jsonPath = Join-Path $OutputPath "ai-attribution-analysis_$timestamp.json"
        $jsonReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding utf8
        Write-Host "JSON report saved: $jsonPath" -ForegroundColor Green
    }
    
    # HTML Report (if requested)
    if ($Format -in @("HTML", "All")) {
        $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>AI Attribution Analysis Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #007bff; }
        .commits-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        .commits-table th, .commits-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        .commits-table th { background-color: #007bff; color: white; }
        .ai-score { font-weight: bold; }
        .high { color: #dc3545; } .medium { color: #fd7e14; } .low { color: #28a745; }
    </style>
</head>
<body>
    <div class="header">
        <h1>AI Attribution Analysis Report</h1>
        <p>Generated: $(Get-Date) | Repository: $(Split-Path -Leaf (Get-Location))</p>
    </div>
    
    <div class="stats">
        <div class="stat-card">
            <h3>Total Commits</h3>
            <p style="font-size: 2em; margin: 0;">$($stats.TotalCommits)</p>
        </div>
        <div class="stat-card">
            <h3>AI-Assisted</h3>
            <p style="font-size: 2em; margin: 0;">$($stats.AIAssistedCommits)</p>
        </div>
        <div class="stat-card">
            <h3>AI Rate</h3>
            <p style="font-size: 2em; margin: 0;">$([Math]::Round(($stats.AIAssistedCommits / $stats.TotalCommits) * 100, 1))%</p>
        </div>
        <div class="stat-card">
            <h3>Avg Score</h3>
            <p style="font-size: 2em; margin: 0;">$([Math]::Round($stats.AverageAIScore, 2))</p>
        </div>
    </div>
    
    <h2>Top AI-Assisted Commits</h2>
    <table class="commits-table">
        <thead>
            <tr><th>Score</th><th>Hash</th><th>Author</th><th>Likely AI</th><th>Message</th></tr>
        </thead>
        <tbody>
"@
        
        $topCommits = $AnalysisResults | Sort-Object AIScore -Descending | Select-Object -First 20
        foreach ($commit in $topCommits) {
            $scoreClass = if ($commit.AIScore -ge 7) { "high" } elseif ($commit.AIScore -ge 3) { "medium" } else { "low" }
            $htmlReport += "<tr><td class='ai-score $scoreClass'>$($commit.AIScore)</td><td>$($commit.ShortHash)</td><td>$($commit.Author)</td><td>$($commit.PossibleLLM)</td><td>$($commit.Message)</td></tr>"
        }
        
        $htmlReport += @"
        </tbody>
    </table>
</body>
</html>
"@
        
        $htmlPath = Join-Path $OutputPath "ai-attribution-report_$timestamp.html"
        $htmlReport | Out-File -FilePath $htmlPath -Encoding utf8
        Write-Host "HTML report saved: $htmlPath" -ForegroundColor Green
    }
}