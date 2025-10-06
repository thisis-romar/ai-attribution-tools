# PowerShell Gallery Publishing Setup

## Quick Setup for Repository Maintainers

### 1. Get PowerShell Gallery API Key

1. **Visit PowerShell Gallery**: Go to [powershellgallery.com](https://www.powershellgallery.com/)
2. **Sign In**: Use Microsoft account or create new account
3. **Account Settings**: Click your profile → "Account settings"
4. **API Keys**: Navigate to "API Keys" section
5. **Create Key**: Click "Create" and set permissions:
   - ✅ **Push new packages and package versions**
   - ✅ **Push only new package versions of packages matching:**
     - Pattern: `AIAttributionTools`
6. **Copy Key**: Save the generated API key securely

### 2. Configure GitHub Secrets

1. **Repository Settings**: Go to repository → Settings → Secrets and variables → Actions
2. **New Secret**: Click "New repository secret"
3. **Name**: `PSGALLERY_API_KEY`
4. **Value**: Paste your PowerShell Gallery API key
5. **Save**: Click "Add secret"

### 3. Publish via GitHub Actions

**Option A: Release Trigger (Recommended)**
```bash
# Create and push a new release tag
git tag v1.1.1
git push origin v1.1.1

# Then create GitHub release through web interface
# This automatically triggers the publishing workflow
```

**Option B: Manual Trigger**
1. Go to repository → Actions → "Publish to PowerShell Gallery"
2. Click "Run workflow"
3. Enter version (e.g., `1.1.0`)
4. Click "Run workflow"

### 4. Verify Publication

```powershell
# Check PowerShell Gallery
Find-Module AIAttributionTools

# Should show new version with updated ProjectUri
# pointing to https://github.com/thisis-romar/ai-attribution-tools
```

## Manual Publishing (Alternative)

If you prefer to publish directly from your development machine:

```powershell
# Set your API key
$apiKey = "your-api-key-here"

# Navigate to repository root
cd "path\to\ai-attribution-tools"

# Test manifest
Test-ModuleManifest .\AIAttributionTools.psd1

# Publish
Publish-Module -Path . -Repository PSGallery -NuGetApiKey $apiKey -Verbose
```

## Troubleshooting

### "Module already exists" Error
```powershell
# You can only publish new versions, not overwrite existing ones
# Update version in AIAttributionTools.psd1 first
```

### "Invalid API Key" Error
- Verify API key is correct and not expired
- Check GitHub secret is properly configured
- Ensure API key has correct permissions

### "Module validation failed" Error
```powershell
# Test locally first
Test-ModuleManifest .\AIAttributionTools.psd1

# Check for required fields in manifest
```

## Publication Checklist

Before publishing:
- [ ] ✅ Version number updated in `AIAttributionTools.psd1`
- [ ] ✅ `ProjectUri` points to correct GitHub repository
- [ ] ✅ `LicenseUri` is accessible
- [ ] ✅ All required files included
- [ ] ✅ Module passes `Test-ModuleManifest`
- [ ] ✅ GitHub Actions workflow is configured
- [ ] ✅ PowerShell Gallery API key is set in GitHub secrets

## Security Notes

- **Never commit API keys**: Always use GitHub secrets or environment variables
- **Limit permissions**: API keys should have minimal required permissions
- **Rotate regularly**: Update API keys periodically for security
- **Monitor usage**: Check PowerShell Gallery dashboard for download stats