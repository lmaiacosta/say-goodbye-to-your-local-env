# 🚀 Envault

**Simple command-line tool to upload .env files to GitHub Actions Secrets**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org/)
[![GitHub CLI](https://img.shields.io/badge/Requires-GitHub_CLI-blue.svg)](https://cli.github.com/)

A single executable that intelligently uploads your environment variables to GitHub Actions Secrets. No more manual copying and pasting!

## ⚡ One-Command Installation

### Linux (x64)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-linux-amd64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### Linux (ARM64)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-linux-arm64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### macOS (Intel)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-darwin-amd64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### macOS (Apple Silicon)
```bash
curl -L https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-darwin-arm64 -o envault && chmod +x envault && sudo mv envault /usr/local/bin/
```

### Windows (PowerShell)
```powershell
Invoke-WebRequest -Uri "https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/latest/download/envault-windows-amd64.exe" -OutFile "envault.exe"
# Move to a directory in your PATH or run directly
```

## 📋 Prerequisites

- **GitHub CLI** installed and authenticated (`gh auth login`)
- Access to the target repository

## 🎯 Usage

### Basic Commands
```bash
# Upload .env file to current repository
envault -f .env

# Specify repository and environment
envault -f .env.production -r owner/repo -e production

# Preview without uploading (recommended first!)
envault -f .env --dry-run

# Auto-classify without asking
envault -f .env --auto
```

### Environment Examples
```bash
# Development environment (adds DEVELOPMENT_ prefix)
envault -f .env.dev -e development

# Staging environment (adds STAGING_ prefix)
envault -f .env.staging -e staging

# Production environment (no prefix)
envault -f .env.prod -e production

# Different repository
envault -f .env -r myorg/myrepo
```

## 🔧 How it Works

1. **Authenticates** using your GitHub CLI session
2. **Parses** your .env file for variables
3. **Classifies** each variable as Secret or Variable (or asks you)
4. **Encrypts** secrets using GitHub's public key
5. **Uploads** everything to GitHub Actions Secrets

## 🎨 Interactive Mode

By default, Envault asks you about each variable:

```
DATABASE_URL: postgresql://user:pass@host:5432/db
💡 Suggested: SECRET
Choose: [S]ecret, [V]ariable, [K]eep suggestion, [X]skip: k
✅ Uploaded DATABASE_URL
```

Use `--auto` to skip questions and auto-classify.

## 🔐 Smart Classification

Envault automatically detects:

**🔒 Secrets (encrypted, hidden):**
- Variables containing: `password`, `secret`, `key`, `token`, `auth`, `private`
- Long tokens starting with: `sk-`, `ghp_`, `ghs_`

**📝 Variables (public, visible):**
- Everything else (URLs, ports, debug flags, etc.)

## 🌍 Environment Detection

Automatic environment detection from filenames:
- `.env.prod*` → production
- `.env.stag*` → staging
- `.env.dev*` → development
- `.env` → development (default)

## 🚀 Quick Examples

```bash
# First time? Use dry-run to preview
envault -f .env.production --dry-run

# Upload production secrets (no prefix)
envault -f .env.production -e production

# Upload staging with prefix
envault -f .env.staging -e staging

# Auto-mode for CI/CD
envault -f .env --auto -r myorg/myapp -e production
```

## 📖 Complete Reference

```bash
Usage: envault [flags]

Flags:
  -f, --env-file string      Path to .env file (required)
  -r, --repo string          GitHub repository (owner/repo)
  -e, --environment string   Environment (production, staging, development)
      --auto                 Auto classify variables (no prompts)
      --dry-run              Preview without uploading
  -h, --help                 Help for envault
  -v, --version              Version information
```

## 🔒 Security Features

- **Zero local storage** - No credentials stored locally
- **GitHub CLI integration** - Uses your existing authentication
- **Encryption** - Secrets encrypted before upload
- **Smart detection** - Identifies sensitive data patterns
- **Environment separation** - Keeps environments isolated

## 💡 Pro Tips

1. **Always dry-run first**: `envault -f .env --dry-run`
2. **Use auto-mode for CI**: `envault -f .env --auto`
3. **Be careful with production**: Double-check before uploading
4. **Check GitHub Secrets**: Verify uploads in repository settings

## 🛠️ Building from Source

```bash
git clone https://github.com/lmaiacosta/say-goodbye-to-your-local-env.git
cd say-goodbye-to-your-local-env
go build -o envault
sudo mv envault /usr/local/bin/
```

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ for developers who value security and simplicity**
