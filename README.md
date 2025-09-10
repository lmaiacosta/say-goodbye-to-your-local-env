# 🚀 Envault

**Simp## 🚀 Quick Install

### Au## 📋 Prerequisites

- [GitHub CLI](https://cli.github.com/) installed and authenticated
  - Linux/macOS: `gh auth login`
  - Windows: Install from [cli.github.com](https://cli.github.com/) and run `gh auth login`
- Access to the target repositorytic Installation (Linux/macOS)
```bash
curl -sSL https://raw.githubusercontent.com/lmaiacosta/say-goodbye-to-your-local-env/main/install.sh | bash
```

### Manual Installation
1. Download the latest binary for your platform from [releases](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases)
2. Choose the appropriate file:
   - **Linux**: `envault-linux-amd64` or `envault-linux-arm64`
   - **Windows**: `envault-windows-amd64.exe` or `envault-windows-arm64.exe`
   - **macOS**: `envault-darwin-amd64` or `envault-darwin-arm64`
3. Make it executable: `chmod +x envault-*` (Linux/macOS)
4. Move to PATH: `sudo mv envault-* /usr/local/bin/envault`

### Windows Installation
1. Download `envault-windows-amd64.exe` from releases
2. Rename to `envault.exe` and place in a directory in your PATH
3. Or run directly from download locationand-line tool to upload .env files to GitHub Actions Secrets**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org/)
[![GitHub CLI](https://img.shields.io/badge/Requires-GitHub_CLI-blue.svg)](https://cli.github.com/)

A single binary that intelligently uploads your environment variables to GitHub Actions Secrets. No more manual copying and pasting!

## ✨ Features

- **🎯 Smart Classification** - Automatically detects secrets vs variables
- **🌍 Environment Support** - Production, staging, development environments
- **🔒 Secure** - Uses GitHub CLI authentication and encrypts secrets
- **💻 Cross-platform** - Works on Linux, macOS, Windows
- **� Auto-detection** - Detects repository and environment from context
- **🔍 Dry Run** - Preview what will be uploaded before doing it
- **⚡ Simple** - Single binary, no dependencies

## � Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/lmaiacosta/say-goodbye-to-your-local-env/main/install.sh | bash
```

Or download from [releases](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases).

## � Prerequisites

- [GitHub CLI](https://cli.github.com/) installed and authenticated
- Access to the target repository

## 🎯 Usage

### Basic Usage
```bash
# Upload .env file to current repository
envault -f .env

# Specify repository and environment
envault -f .env.production -r owner/repo -e production

# Preview without uploading
envault -f .env --dry-run

# Auto-classify without asking
envault -f .env --auto
```

### Examples
```bash
# Development environment
envault -f .env.dev -e development

# Staging environment
envault -f .env.staging -e staging

# Production environment (be careful!)
envault -f .env.prod -e production

# Different repository
envault -f .env -r myorg/myrepo
```

### Windows Users
On Windows, use Command Prompt or PowerShell:
```cmd
envault.exe -f .env -r owner/repo -e production
```## � How it Works

1. **Authenticates** using your GitHub CLI session
2. **Parses** your .env file for variables
3. **Classifies** each variable as Secret or Variable (or asks you)
4. **Encrypts** secrets using GitHub's public key
5. **Uploads** everything to GitHub Actions Secrets

## � Interactive Mode

By default, Envault will ask you about each variable:

```
DATABASE_URL: postgresql://user:pass@host:5432/db
💡 Suggested: SECRET
Choose: [S]ecret, [V]ariable, [K]eep suggestion, [X]skip: k
✅ Uploaded DATABASE_URL
```

Use `--auto` to skip questions and auto-classify.

## 🔐 Security Features

- **Zero local storage** - No credentials stored locally
- **GitHub CLI integration** - Uses your existing authentication
- **Encryption** - Secrets encrypted before upload
- **Smart detection** - Identifies sensitive data patterns
- **Environment separation** - Keeps environments isolated

## �️ Building from Source

```bash
git clone https://github.com/lmaiacosta/say-goodbye-to-your-local-env.git
cd say-goodbye-to-your-local-env
go build -o envault
sudo mv envault /usr/local/bin/
```

## 📖 Environment Detection

Envault automatically detects environments from filenames:
- `.env.prod*` → production
- `.env.stag*` → staging
- `.env.dev*` → development
- `.env` → development (default)

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## � License

MIT License - see [LICENSE](LICENSE) for details.

---

**Made with ❤️ for developers who value security and simplicity**