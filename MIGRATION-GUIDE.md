# AI Attribution Tools - Migration Guide

## Repository Migration Status

**✅ COMPLETED**: AI Attribution Tools has been successfully migrated from the WhatsApp receipts project to its own dedicated repository.

- **Old Location**: `emblem.io-whatsapp-receipts/AIAttributionTools/`
- **New Location**: [https://github.com/thisis-romar/ai-attribution-tools](https://github.com/thisis-romar/ai-attribution-tools)
- **Version Update**: v1.0.0 → v1.1.0

## For Existing Users

### PowerShell Gallery Update (In Progress)

**Current Status**:
- PowerShell Gallery currently shows `v1.0.0` pointing to the old repository
- `v1.1.0` will redirect to the new dedicated repository

**Installation**:
```powershell
# Current (will be updated automatically)
Install-Module AIAttributionTools

# For latest version from new repository
Install-Module AIAttributionTools -Force -AllowClobber
```

**Manual Installation** (if PowerShell Gallery update is pending):
```powershell
# Clone the new repository
git clone https://github.com/thisis-romar/ai-attribution-tools.git

# Import the module manually
Import-Module ./ai-attribution-tools/AIAttributionTools.psd1

# Or install locally
Copy-Item ./ai-attribution-tools $env:PSModulePath.Split(';')[0] -Recurse
```

## For New Users

### Quick Start
```powershell
# Install from PowerShell Gallery
Install-Module AIAttributionTools

# Basic usage
Invoke-LLMCommitAnalysis -ShowDetails
```

### GitHub Installation
```powershell
# Clone and use directly
git clone https://github.com/thisis-romar/ai-attribution-tools.git
cd ai-attribution-tools
Import-Module .\AIAttributionTools.psd1
```

## Repository Changes

### What Moved
- ✅ **AIAttributionTools Module**: Complete PowerShell module with manifest
- ✅ **Core Detection Logic**: `Test-AICommitPattern.ps1` with advanced AI detection
- ✅ **Public API**: `Invoke-LLMCommitAnalysis.ps1` unified interface  
- ✅ **Documentation**: Complete docs/ folder with API and configuration guides
- ✅ **Examples**: Working examples and basic analysis scripts
- ✅ **Legacy Tools**: Original scripts preserved in legacy-tools/ folder
- ✅ **CI/CD**: GitHub Actions workflows for automated testing and publishing

### What Stayed in WhatsApp Project
- ✅ **Business Logic**: WhatsApp receipts processing system
- ✅ **Investor Presentation**: Pitch deck and business content
- ✅ **Cloud Integration**: Google Cloud Document AI and WhatsApp API
- ✅ **Project Structure**: Node.js backend and frontend systems

## Migration Benefits

### For Developers
- **🎯 Focused Purpose**: AI Attribution Tools now has a single, clear mission
- **🔄 Reusability**: Can be used across multiple projects and repositories
- **📦 Easy Distribution**: Direct PowerShell Gallery and GitHub access
- **🚀 Community Ready**: Professional repository structure for contributions

### For Projects
- **🧹 Clean Architecture**: Each project focuses on its core business logic
- **📚 Better Documentation**: Dedicated documentation for each system
- **🔧 Easier Maintenance**: Separate repositories reduce complexity
- **⚡ Faster Setup**: Install only what you need for each project

## PowerShell Gallery Publishing

### Automated Publishing
The repository includes GitHub Actions workflow for automated PowerShell Gallery publishing:
- Triggers on releases and manual workflow dispatch
- Validates module manifest before publishing
- Publishes to PowerShell Gallery with proper versioning

### Manual Publishing (Maintainers Only)
```powershell
# Ensure you have PowerShell Gallery API key
$apiKey = "your-powershell-gallery-api-key"

# Test the manifest
Test-ModuleManifest .\AIAttributionTools.psd1

# Publish to PowerShell Gallery
Publish-Module -Path . -Repository PSGallery -NuGetApiKey $apiKey -Verbose
```

## Getting PowerShell Gallery API Key

1. **Create PowerShell Gallery Account**: Visit [powershellgallery.com](https://www.powershellgallery.com/)
2. **Generate API Key**: Go to Account Settings → API Keys → Create
3. **Set Permissions**: Select appropriate permissions for publishing
4. **Add to GitHub Secrets**: Store as `PSGALLERY_API_KEY` in repository secrets

## Troubleshooting

### Module Not Found
```powershell
# Check current installation
Get-Module AIAttributionTools -ListAvailable

# Force refresh from PowerShell Gallery
Uninstall-Module AIAttributionTools -Force
Install-Module AIAttributionTools -Force
```

### Version Conflicts
```powershell
# Check all versions
Get-Module AIAttributionTools -ListAvailable | Format-Table Version, Path

# Install specific version
Install-Module AIAttributionTools -RequiredVersion 1.1.0 -Force
```

### Import Issues
```powershell
# Import with verbose output to see issues
Import-Module AIAttributionTools -Verbose

# Check module dependencies
Test-ModuleManifest (Get-Module AIAttributionTools).Path
```

## Support

- **Issues**: [GitHub Issues](https://github.com/thisis-romar/ai-attribution-tools/issues)
- **Documentation**: [README.md](README.md) and [docs/](docs/) folder
- **Examples**: [examples/](examples/) folder for usage patterns

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to AI Attribution Tools.

---

**Migration Completed**: AI Attribution Tools is now a mature, independent PowerShell module ready for community use across multiple projects.