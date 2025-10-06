@{
    # Script module or binary module file associated with this manifest
    RootModule = 'AIAttributionTools.psm1'

    # Version number of this module - Following Semantic Versioning (SemVer)
    ModuleVersion = '1.1.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'f8c4d8b2-6e3a-4b5f-9c7d-2a1e8f4b9d6c'

    # Author of this module
    Author = 'Emblem.iO Team'

    # Company or vendor of this module
    CompanyName = 'Emblem.iO'

    # Copyright statement for this module
    Copyright = '(c) 2025 Emblem.iO. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'AI Attribution Tools for GitHub development workflows. Detect AI-assisted commits, analyze chat history, and manage proper attribution in VS Code Copilot environments. Essential for AI development transparency and compliance.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Invoke-LLMCommitAnalysis',
        'Get-AIAttributedCommits', 
        'Set-AICommitAuthor',
        'New-LLMReport',
        'Test-AICommitPattern',
        'Install-AIAttributionEnvironment'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @('llm-analyze', 'ai-commits', 'ai-attr')

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module for discoverability
            Tags = @(
                'AI', 'Attribution', 'GitHub', 'Copilot', 'LLM', 'Git', 
                'Development', 'Automation', 'VSCode', 'Transparency',
                'ChatGPT', 'Claude', 'AI-Development', 'Commit-Analysis'
            )

            # A URL to the license for this module
            LicenseUri = 'https://github.com/thisis-romar/ai-attribution-tools/blob/main/LICENSE'

            # A URL to the main website for this project
            ProjectUri = 'https://github.com/thisis-romar/ai-attribution-tools'

            # A URL to an icon representing this module
            IconUri = 'https://raw.githubusercontent.com/thisis-romar/ai-attribution-tools/main/docs/ai-attribution-icon.png'

            # Release notes for this version
            ReleaseNotes = @"
# AI Attribution Tools v1.0.0

## 🚀 Initial Community Release

### Features
- **LLM Commit Identifier**: Advanced AI-assisted commit detection (0-11+ scoring system)
- **Chat History Parser**: VS Code Copilot conversation analysis with git correlation
- **Attribution Corrector**: Automated git commit author correction for AI transparency
- **Helper Functions**: Easy-to-use wrapper functions for quick analysis

### VS Code Copilot Integration
- Out-of-the-box setup for Windows 11 environments
- Automated installation scripts
- Workspace configuration templates
- Extension recommendations

### Community Distribution
- PowerShell Gallery publishing ready
- GitHub Actions automation
- Comprehensive documentation
- Installation via `Install-Module AIAttributionTools`

For detailed usage: https://github.com/thisis-romar/ai-attribution-tools/blob/main/AIAttributionTools/README.md
"@

            # Prerelease string (if this is a prerelease version)
            # Prerelease = 'alpha'

            # Flag to indicate whether the module requires explicit user acceptance
            RequireLicenseAcceptance = $false

            # External dependent modules
            ExternalModuleDependencies = @()
        }
    }

    # HelpInfo URI for this module
    HelpInfoURI = 'https://github.com/thisis-romar/ai-attribution-tools/blob/main/docs/help/'

    # Default prefix for commands exported from this module
    DefaultCommandPrefix = ''
}
