# 🚀 Envault

**Upload .env files to GitHub Actions Secrets in one command**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Single executable. No dependencies. Just works.

## ⚡ Install (Copy & Paste)

### Linux
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-linux-amd64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### macOS (Intel)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-darwin-amd64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### macOS (Apple Silicon)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-darwin-arm64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### Windows (PowerShell as Admin)
```powershell
Invoke-WebRequest -Uri "https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-windows-amd64.exe" -OutFile "$env:ProgramFiles\envault.exe"
```

## ✅ Test Installation
```bash
envault --version
```

## 📋 Setup (One Time)

1. **Install GitHub CLI** (if not installed):
   ```bash
   # Linux/macOS
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update && sudo apt install gh
   
   # macOS
   brew install gh
   
   # Windows
   winget install --id GitHub.cli
   ```

2. **Login to GitHub**:
   ```bash
   gh auth login
   ```

## 🎯 Usage

### Basic
```bash
# Upload .env to current repository
envault -f .env

# Preview first (recommended)
envault -f .env --dry-run

# Specific repository
envault -f .env -r owner/repo
```

### Environments
```bash
# Production (no prefix)
envault -f .env.prod -e production

# Staging (STAGING_ prefix)
envault -f .env.staging -e staging

# Development (DEVELOPMENT_ prefix) 
envault -f .env.dev -e development
```

### Auto Mode (No Questions)
```bash
# For CI/CD pipelines
envault -f .env --auto -r owner/repo -e production
```

## 🔧 How It Works

1. Reads your `.env` file
2. Uses GitHub CLI to authenticate
3. Asks if each variable is a SECRET or VARIABLE
4. Encrypts secrets and uploads to GitHub Actions

## 🔐 Smart Detection

**Automatically detects secrets:**
- Contains: `password`, `secret`, `key`, `token`, `auth`
- Starts with: `sk-`, `ghp_`, `ghs_`
- Long random strings

## 💡 Quick Tips

- **Always dry-run first**: `--dry-run`
- **Use auto-mode for CI**: `--auto`
- **Environment prefixes**: staging gets `STAGING_`, dev gets `DEVELOPMENT_`
- **Production has no prefix**

## 🚀 Examples

```bash
# First time - see what will happen
envault -f .env.production --dry-run

# Upload production secrets
envault -f .env.production -e production

# Upload staging with auto-classification
envault -f .env.staging -e staging --auto

# Different repository
envault -f .env -r mycompany/myapp -e production
```

## 📖 All Flags

```
  -f, --env-file string      Path to .env file (required)
  -r, --repo string          GitHub repository (owner/repo)
  -e, --environment string   Environment (production, staging, development)
      --auto                 Auto classify (no questions)
      --dry-run              Preview only
  -h, --help                 Show help
  -v, --version              Show version
```

## 🛠️ Build from Source

```bash
git clone https://github.com/lmaiacosta/say-goodbye-to-your-local-env.git
cd say-goodbye-to-your-local-env
go build -o envault
sudo mv envault /usr/local/bin/
```

---

**Made with ❤️ for developers who value security and simplicity**
