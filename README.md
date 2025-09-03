# � Envault

**Say NO to lazy work! Stop executing lazy scripts to fill your applications with environment variables and secrets.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![GitHub CLI](https://img.shields.io/badge/Requires-GitHub_CLI-blue.svg)](https://cli.github.com/)

This interactive tool makes you **THINK** about each variable while automating the boring parts. First edition: GitHub compatibility. Coming soon: BitBucket support. Because being smart about secrets is cooler than being lazy! 🔐✨

## ✨ Features

### 🎯 **Smart Classification**
- **Automatic detection** of secrets vs environment variables
- **Interactive mode** - you decide each variable
- **Auto mode** - uses intelligent pattern matching
- **Dry run** - preview before uploading

### 🌍 **Environment Management**
- **Production** - Direct upload without prefixes
- **Staging** - `STAGING_` prefixed variables
- **Development** - `DEVELOPMENT_` prefixed variables
- **Custom environments** - easily extensible

### 🔒 **Security First**
- **GitHub Secrets** for sensitive data (encrypted, hidden from logs)
- **GitHub Variables** for public configuration (visible in workflows)
- **Smart pattern detection** for passwords, keys, tokens
- **Empty value validation** and security checks

### 💡 **User Experience**
- **Interactive menus** with clear options
- **Color-coded output** for better visibility
- **Progress tracking** and detailed summaries
- **Comprehensive help** and usage examples

## 🚀 Quick Start

### Prerequisites

1. **GitHub CLI** installed and authenticated:
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Authenticate
gh auth login
```

2. **Environment files** in your project root:
```bash
.env.production    # Production variables
.env.staging       # Staging variables
.env.development   # Development variables
.env.local         # Local overrides (optional)
```

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/say-goodbye-to-your-local-env.git
cd envault

# Make executable
chmod +x byebyenv.sh

# Run interactive mode
./byebyenv.sh
```

## 📖 Usage

### Interactive Mode (Recommended)
```bash
./byebyenv.sh
```
- Choose your environment from menu
- Decide each variable: SECRET, VARIABLE, or SKIP
- Get smart recommendations with full control

### Auto Mode (Smart Classification)
```bash
./byebyenv.sh production --auto
./byebyenv.sh staging --auto
./byebyenv.sh development --auto
```

### Dry Run (Preview Only)
```bash
./byebyenv.sh production --dry-run
./byebyenv.sh staging --dry-run --auto
```

### Help
```bash
./byebyenv.sh --help
```

## 🗂️ Environment File Structure

### Example `.env.production`
```bash
# Database Configuration
DATABASE_HOST=db.example.com
DATABASE_PORT=3306
DATABASE_NAME=myapp_prod
DATABASE_USER=admin              # → SECRET
DATABASE_PASSWORD=secret123      # → SECRET

# API Configuration
API_BASE_URL=https://api.example.com
OPENAI_API_KEY=sk-1234567890     # → SECRET
NEXT_PUBLIC_APP_NAME=MyApp       # → VARIABLE

# Authentication
NEXTAUTH_URL=https://myapp.com
NEXTAUTH_SECRET=jwt_secret_key   # → SECRET
JWT_EXPIRATION=7d                # → VARIABLE

# Feature Flags
ENABLE_ANALYTICS=true            # → VARIABLE
NODE_ENV=production              # → VARIABLE
```

## 🔍 Smart Classification Logic

### Automatically Detected as **SECRETS** (Encrypted):
- `*_PASSWORD`, `*_SECRET`, `*_KEY`, `*_TOKEN`
- `DATABASE_PASSWORD`, `DATABASE_USER`, `MYSQL_PASSWORD`
- `NEXTAUTH_SECRET`, `JWT_SECRET`, `ENCRYPTION_KEY`
- `*API_KEY*` (OpenAI, Google, AWS, etc.)
- `KEYCLOAK_CLIENT_SECRET`, `OAUTH_CLIENT_SECRET`

### Automatically Detected as **VARIABLES** (Public Config):
- `NODE_ENV`, `NEXT_PUBLIC_*`
- Database hosts, ports, names
- API endpoints and URLs
- Feature flags and configuration
- Everything else not matching secret patterns

## 🌍 Environment Mapping

| Environment | Files Processed | Variable Naming | Use Case |
|-------------|----------------|-----------------|----------|
| `production` | `.env.production` + `.env.local` | No prefix | Live deployment |
| `staging` | `.env.staging` + `.env.local` | `STAGING_*` | Testing environment |
| `development` | `.env.development` + `.env.local` | `DEVELOPMENT_*` | Dev environment |

## 🎨 Output Examples

### Interactive Classification
```bash
🤔 Classify: DATABASE_PASSWORD
   Smart guess: SECRET (recommended)
   1) SECRET (encrypted, hidden from logs)
   2) VARIABLE (public config, visible in logs)
   3) SKIP (don't upload this)
   Choose (1/2/3) or press Enter for smart guess:
```

### Upload Progress
```bash
🔐 Uploading SECRET: DATABASE_PASSWORD...
✅ SUCCESS

📝 Setting VARIABLE: API_BASE_URL = https://api.example.com
✅ SUCCESS

⏭️  Skipping TEMP_DEBUG_FLAG
```

### Summary
```bash
🎉 Upload completed for production!
📊 Uploaded: 15
📊 Skipped: 2

🔗 View secrets: https://github.com/user/repo/settings/secrets/actions
🔗 View variables: https://github.com/user/repo/settings/variables/actions
```

## 🛠️ Configuration

### Repository Setup
Edit the script to set your repository:
```bash
# Configuration
REPO="yourusername/yourrepo"
```

### Custom Classification
Add your own patterns to the `is_secret_smart()` function:
```bash
is_secret_smart() {
    local name="$1"
    [[ "$name" =~ ^YOUR_CUSTOM_PATTERN$ ]] || \
    [[ "$name" =~ ^.*_(PASSWORD|SECRET|KEY).*$ ]]
}
```

## 🔧 Advanced Usage

### Custom Environment Files
```bash
# Modify ENV_FILES array for custom environments
case "$ENVIRONMENT" in
    "production")
        ENV_FILES+=(".env.production" ".env.local")
        ;;
    "testing")
        ENV_FILES+=(".env.testing" ".env.shared")
        ;;
esac
```

### Integration with CI/CD
```yaml
# .github/workflows/deploy.yml
name: Deploy Secrets
on:
  push:
    branches: [main]

jobs:
  upload-secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Upload production secrets
        run: |
          chmod +x byebyenv.sh
          ./byebyenv.sh production --auto
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
```bash
git clone https://github.com/yourusername/say-goodbye-to-your-local-env.git
cd envault
chmod +x byebyenv.sh

# Test in dry-run mode
./byebyenv.sh --dry-run
```

### Code Style
- Follow shellcheck recommendations
- Use descriptive variable names
- Add comments for complex logic
- Test with different environments

## 📋 Roadmap

- [ ] **Multi-repository support** - Upload to multiple repos at once
- [ ] **Config file support** - `.envaultrc` for repository settings
- [ ] **Backup/restore** - Download existing secrets for backup
- [ ] **Template system** - Predefined environment templates
- [ ] **Integration plugins** - Support for other platforms (GitLab, Bitbucket)
- [ ] **Encryption at rest** - Local encryption for sensitive env files

## 🐛 Troubleshooting

### Common Issues

**GitHub CLI not authenticated:**
```bash
gh auth status
gh auth login
```

**Permission denied:**
```bash
chmod +x byebyenv.sh
```

**Repository not found:**
- Check repository name in script configuration
- Ensure you have admin access to the repository

**Environment file not found:**
```bash
# Create missing files
touch .env.production .env.staging .env.development
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **GitHub CLI team** for the excellent command-line interface
- **Bash community** for shell scripting best practices
- **Open source contributors** who help improve this tool

## 📞 Support

- 🐛 **Bug reports**: [GitHub Issues](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/issues)
- 💡 **Feature requests**: [GitHub Discussions](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/wiki)

---

**Made with ❤️ for the developer community**

*Secure your environment variables, simplify your deployments.*