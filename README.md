# 🚀 ByeByeEnv

**Upload .env files to GitHub Actions Secrets in one command**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org/)

Single executable. No dependencies. Works with any .env format.

## ⚡ Install (Copy & Paste)

### Linux (Intel/AMD64)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/byebyeenv-linux-amd64 -o byebyeenv && chmod +x byebyeenv && sudo mv byebyeenv /usr/local/bin/
```

### Linux (ARM64)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/byebyeenv-linux-arm64 -o byebyeenv && chmod +x byebyeenv && sudo mv byebyeenv /usr/local/bin/
```

### macOS (Intel)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/byebyeenv-darwin-amd64 -o byebyeenv && chmod +x byebyeenv && sudo mv byebyeenv /usr/local/bin/
```

### macOS (Apple Silicon)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/byebyeenv-darwin-arm64 -o byebyeenv && chmod +x byebyeenv && sudo mv byebyeenv /usr/local/bin/
```

### Windows (PowerShell as Admin)
```powershell
Invoke-WebRequest -Uri "https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/byebyeenv-windows-amd64.exe" -OutFile "$env:ProgramFiles\byebyeenv.exe"
```

## ✅ Test Installation
```bash
byebyeenv --version
```

## 📋 Setup (One Time Only)

Install and authenticate GitHub CLI:
```bash
# Install GitHub CLI (if not installed)
# Linux/Ubuntu:
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh

# macOS:
brew install gh

# Windows:
winget install GitHub.cli

# Login to GitHub
gh auth login
```

## 🎯 Usage

### Basic Usage
```bash
# Upload .env to current repository
byebyeenv -f .env

# Preview first (recommended)
byebyeenv -f .env --dry-run

# Specific repository
byebyeenv -f .env -r owner/repo

# Auto-classify (no questions)
byebyeenv -f .env --auto
```

### Environment Support
```bash
# Production (no prefix)
byebyeenv -f .env.prod -e production

# Staging (STAGING_ prefix)
byebyeenv -f .env.staging -e staging

# Development (DEVELOPMENT_ prefix)
byebyeenv -f .env.dev -e development
```

## 📝 Supported .env Formats

ByeByeEnv works with any .env format:

```bash
# Standard format
DATABASE_URL=postgresql://localhost:5432/db
API_KEY=sk-1234567890

# Export format (like your example!)
export DIGITALOCEAN_TOKEN="dop_v1_token"
export API_SECRET="secret_value"

# Mixed format
export DATABASE_URL="postgresql://localhost/db"
DEBUG=true
PORT=3000
```

## 🔧 How It Works

1. **Reads** your .env file (any format)
2. **Authenticates** using GitHub CLI
3. **Classifies** variables as SECRET or VARIABLE
4. **Encrypts** secrets using GitHub's public key
5. **Uploads** to GitHub Actions Secrets

## 🔐 Smart Detection

**Automatically classifies as SECRET:**
- Contains: `password`, `secret`, `key`, `token`, `auth`, `private`, `credential`
- Starts with: `sk-`, `ghp_`, `ghs_`, `dop_v1_`
- Long random-looking strings

**Everything else as VARIABLE**

## � Examples

```bash
# First time - see what will happen
byebyeenv -f .env.production --dry-run

# Upload production secrets (careful!)
byebyeenv -f .env.production -e production

# Upload staging with auto-classification
byebyeenv -f .env.staging -e staging --auto

# Different repository
byebyeenv -f .env -r mycompany/myapp

# Current directory auto-detection
byebyeenv -f .env
```

## 🚀 Quick Start

```bash
# 1. Install byebyeenv (see commands above)

# 2. Setup GitHub CLI (one time)
gh auth login

# 3. Upload your .env file
byebyeenv -f .env --dry-run    # Preview first
byebyeenv -f .env              # Upload for real
```

## 📖 All Options

```
Usage: byebyeenv [flags]

Flags:
  -f, --env-file string      Path to .env file (required)
  -r, --repo string          GitHub repository (owner/repo)
  -e, --environment string   Environment (production, staging, development)
      --dry-run              Preview without uploading
      --auto                 Auto classify variables (no prompts)
  -h, --help                 Help
  -v, --version              Version
```

## 🛠️ Build from Source

```bash
git clone https://github.com/lmaiacosta/say-goodbye-to-your-local-env.git
cd say-goodbye-to-your-local-env
make build
sudo make install
```

## 🔍 Troubleshooting

**"GitHub CLI not found"**
- Install GitHub CLI first: https://cli.github.com/

**"not authenticated"**
- Run: `gh auth login`

**"repository not specified"**
- Use: `byebyeenv -f .env -r owner/repo`
- Or run in a git repository

## ⭐ Features

- ✅ **Export syntax support** - Works with `export VAR="value"`
- ✅ **Smart classification** - Auto-detects secrets vs variables
- ✅ **Environment prefixes** - Staging gets `STAGING_`, dev gets `DEVELOPMENT_`
- ✅ **Dry-run mode** - Preview before uploading
- ✅ **Auto-detection** - Repository and environment detection
- ✅ **Cross-platform** - Linux, macOS, Windows
- ✅ **Secure** - GitHub CLI auth + encryption
- ✅ **Single binary** - No dependencies

---

**Made with ❤️ for developers who value security and simplicity**

**⭐ Star this repo if it helped you!**
