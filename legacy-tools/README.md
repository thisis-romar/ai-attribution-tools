# Chat History Analysis Tools - WhatsApp Receipts Project

This directory contains tools for analyzing VS Code Copilot chat history and correlating it with git commit patterns for the WhatsApp receipts processing system project.

## Available Tools

### 1. ChatHistoryParser.ps1
**Main Parser Tool** - Comprehensive chat history analysis with git integration

**Usage:**
```powershell
# Basic analysis
.\tools\ChatHistoryParser.ps1

# Detailed analysis with git commits
.\tools\ChatHistoryParser.ps1 -IncludeGitCommits -Verbose

# Custom path analysis
.\tools\ChatHistoryParser.ps1 -ChatHistoryPath "C:\Custom\Path" -OutputPath "custom-analysis.json"
```

**Parameters:**
- `-ChatHistoryPath` - Specific directory to search for chat files
- `-OutputPath` - Where to save analysis results (default: chat-analysis.json)
- `-IncludeGitCommits` - Include git commit correlation analysis
- `-Verbose` - Show detailed processing information

### 2. ChatAnalysisHelpers.ps1
**Helper Functions** - Easy-to-use wrapper functions

**Usage:**
```powershell
# Load helper functions
. .\tools\ChatAnalysisHelpers.ps1

# Use convenience functions
Analyze-Chats                    # Quick analysis
Analyze-ChatsDetailed           # Detailed with git commits
Analyze-ChatsCustom -Path "..."  # Custom path analysis
Show-ChatAnalysisHelp           # Display help
```

## What It Analyzes

### Chat History Data
- VS Code Copilot conversation files (.json, .log)
- Chat timestamps and patterns
- Conversation topics and themes
- File locations and sources

### Git Integration (with -IncludeGitCommits)
- Recent commit history (last week)
- Commit messages and patterns
- Author information and timestamps
- Correlation with chat activity

### Search Locations
The parser automatically searches common VS Code data locations:
- `%APPDATA%\Code\User\workspaceStorage`
- `%APPDATA%\Code\CachedExtensions`  
- `%APPDATA%\Code\logs`
- VS Code Copilot extension directories

## Output Format

The analysis generates JSON output with:

```json
{
  "GeneratedAt": "2025-01-06 16:00:00",
  "ProjectPath": "H:\\- emblem.iO -\\emblem.io-whatsapp-recipts",
  "Analysis": {
    "TotalConversations": 15,
    "TotalCommits": 8,
    "ConversationsByType": {
      "JSON": 12,
      "LOG": 3
    },
    "TimeRange": {
      "Earliest": "2025-01-01T10:00:00",
      "Latest": "2025-01-06T15:30:00"
    },
    "Recommendations": [
      "Found 15 chat-related files",
      "Found 8 recent git commits", 
      "Consider correlating chat timestamps with commit times"
    ]
  },
  "Conversations": [...],
  "Commits": [...],
  "Tools": {
    "Parser": "ChatHistoryParser.ps1",
    "Version": "1.0",
    "Project": "WhatsApp Receipts Processing System"
  }
}
```

## Quick Start

1. **Open PowerShell in project root**
2. **Load helper functions:**
   ```powershell
   . .\tools\ChatAnalysisHelpers.ps1
   ```
3. **Run analysis:**
   ```powershell
   Analyze-ChatsDetailed
   ```
4. **View results:**
   ```powershell
   Get-Content detailed-chat-analysis.json | ConvertFrom-Json
   ```

## Integration with WhatsApp Project

These tools help analyze:
- Development conversation patterns for the WhatsApp receipts system
- Correlation between Copilot assistance and code commits
- Workflow optimization opportunities
- Documentation of development decision-making process

## Troubleshooting

**No chat files found?**
- Try specifying a custom path with `-ChatHistoryPath`
- Check VS Code data directory permissions
- Ensure VS Code Copilot extension is installed and has been used

**Git integration not working?**
- Ensure you're in a git repository (`git status`)
- Check git is installed and accessible from PowerShell
- Verify git log permissions

**Output file issues?**
- Check write permissions in target directory
- Specify a different output path with `-OutputPath`
- Run PowerShell as administrator if needed

## Project Context

Part of the **WhatsApp Receipts Processing System** - a comprehensive business project featuring:
- Cloud-native receipt processing with Google Document AI
- WhatsApp Business API integration  
- Investor presentation platform with professional design
- Cross-browser testing and quality assessment tools

These analysis tools support development workflow optimization and project documentation.