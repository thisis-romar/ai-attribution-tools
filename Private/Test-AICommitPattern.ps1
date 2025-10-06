# Core AI Detection Logic - Private Functions
# Extracted from LLMCommitIdentifier.ps1 and enhanced for module use

function Test-AICommitPattern {
    <#
    .SYNOPSIS
    Core AI detection algorithm with sophisticated pattern recognition.
    
    .DESCRIPTION
    Analyzes commit messages and metadata using advanced pattern matching 
    to identify AI assistance likelihood. Implements 0-11+ scoring system
    with multiple detection categories.
    
    .PARAMETER Commits
    Array of commit objects to analyze
    
    .PARAMETER ShowDetails
    Display detailed scoring information
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Commits,
        
        [switch]$ShowDetails
    )
    
    # Enhanced AI pattern detection arrays
    $aiIndicators = @{
        "High Probability" = @(
            "comprehensive", "implementation", "integration", "sophisticated", 
            "systematic", "optimization", "refactoring", "enhancement",
            "architecture", "infrastructure", "methodology", "framework"
        )
        "Medium Probability" = @(
            "setup", "configure", "enhance", "update", "create", "improve",
            "initialize", "establish", "develop", "construct", "build"
        )
        "AI Tools Mentioned" = @(
            "copilot", "claude", "ai", "assistant", "llm", "chatgpt", "gpt-4",
            "cursor", "tabnine", "codewhisperer", "intellicode", "codeium"
        )
        "Technical Patterns" = @(
            "typescript", "eslint", "prettier", "webpack", "babel", "jest",
            "dockerfile", "kubernetes", "cicd", "pipeline", "automation"
        )
        "Documentation Patterns" = @(
            "readme", "documentation", "comments", "jsdoc", "swagger", "api-docs",
            "changelog", "contributing", "license", "usage-examples"
        )
    }
    
    # Conventional commit pattern (strong AI indicator)
    $conventionalCommitPattern = "^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\(.+\))?: .+"
    
    $analysisResults = @()
    
    foreach ($commit in $Commits) {
        $aiScore = 0
        $indicators = @()
        $commitText = "$($commit.message) $($commit.author)".ToLower()
        
        if ($ShowDetails) {
            Write-Host "Analyzing commit: $($commit.hash)" -ForegroundColor Gray
        }
        
        # Category-based pattern detection with scoring
        foreach ($category in $aiIndicators.Keys) {
            $categoryHits = 0
            foreach ($pattern in $aiIndicators[$category]) {
                if ($commitText -match [regex]::Escape($pattern)) {
                    $categoryHits++
                    
                    # Scoring based on category importance
                    switch ($category) {
                        "High Probability" { $aiScore += 3 }
                        "Medium Probability" { $aiScore += 2 }  
                        "AI Tools Mentioned" { $aiScore += 5 }
                        "Technical Patterns" { $aiScore += 1.5 }
                        "Documentation Patterns" { $aiScore += 1 }
                    }
                    
                    $indicators += "$category`: $pattern"
                    
                    if ($ShowDetails) {
                        Write-Host "  Match: $category -> $pattern" -ForegroundColor Yellow
                    }
                }
            }
            
            # Bonus for multiple hits in same category (suggests AI comprehensiveness)
            if ($categoryHits -gt 2) {
                $aiScore += 1
                $indicators += "$category`: Multiple Patterns (+1 bonus)"
            }
        }
        
        # Conventional commit format detection
        if ($commit.message -match $conventionalCommitPattern) {
            $aiScore += 2
            $indicators += "Conventional Commit Format"
            
            if ($ShowDetails) {
                Write-Host "  Conventional commit detected (+2)" -ForegroundColor Green
            }
        }
        
        # Message length analysis (AI tends to be comprehensive)
        $messageLength = $commit.message.Length
        if ($messageLength -gt 50) {
            $lengthBonus = [Math]::Min(2, [Math]::Floor($messageLength / 50))
            $aiScore += $lengthBonus
            $indicators += "Detailed Message Length: $messageLength chars (+$lengthBonus)"
        }
        
        # Timestamp pattern analysis (AI often used during intense coding sessions)
        if ($commit.date) {
            $commitTime = [DateTime]::Parse($commit.date)
            $hour = $commitTime.Hour
            
            # AI assistance often used during late night coding (higher likelihood)
            if (($hour -ge 22) -or ($hour -le 6)) {
                $aiScore += 0.5
                $indicators += "Late Night Coding Pattern (+0.5)"
            }
            
            # Rapid commits suggest AI assistance
            # (This would need previous commit for comparison - simplified here)
            if ($commit.message -match "(rapid|quick|fast|immediate)") {
                $aiScore += 1
                $indicators += "Rapid Development Indicator (+1)"
            }
        }
        
        # File type analysis (some file types more likely to use AI)
        if ($commit.message -match "\.(ts|js|py|cs|java|cpp|h|md|json|yml|yaml|dockerfile)") {
            $aiScore += 0.5
            $indicators += "AI-Friendly File Types (+0.5)"
        }
        
        # Calculate AI likelihood based on score
        $aiLikelihood = switch ($aiScore) {
            { $_ -ge 8 } { "Very High" }
            { $_ -ge 5 } { "High" }
            { $_ -ge 3 } { "Medium" }
            { $_ -ge 1 } { "Low" }
            default { "Minimal" }
        }
        
        # Determine most likely AI model based on patterns
        $likelyModel = "Human"
        if ($aiScore -ge 3) {
            if ($commitText -match "copilot") { $likelyModel = "GitHub Copilot" }
            elseif ($commitText -match "claude") { $likelyModel = "Claude AI" }
            elseif ($commitText -match "(chatgpt|gpt-4|openai)") { $likelyModel = "ChatGPT" }
            elseif ($commitText -match "cursor") { $likelyModel = "Cursor AI" }
            else { $likelyModel = "AI Assistant (Generic)" }
        }
        
        if ($ShowDetails) {
            Write-Host "  Final Score: $aiScore -> $aiLikelihood" -ForegroundColor Cyan
        }
        
        # Create analysis result
        $analysisResults += [PSCustomObject]@{
            Hash         = $commit.hash
            ShortHash    = $commit.short
            Message      = $commit.message
            Author       = $commit.author
            Date         = $commit.date
            AIScore      = [Math]::Round($aiScore, 1)
            AILikelihood = $aiLikelihood
            Indicators   = $indicators
            PossibleLLM  = $likelyModel
        }
    }
    
    return $analysisResults
}