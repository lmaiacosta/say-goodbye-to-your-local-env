lmc/projetos/envault/CONTRIBUTING.md
# Contributing to Envault

Thank you for your interest in contributing to Envault! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Bash 4.0 or higher
- GitHub CLI installed and configured
- Basic understanding of environment variables and GitHub Actions

### Development Setup
```bash
# Clone the repository
git clone https://github.com/lmaiacosta/say-goodbye-to-your-local-env.git
cd envault

# Make the script executable
chmod +x byebyenv.sh

# Test in dry-run mode
./byebyenv.sh --dry-run
```

## 📋 How to Contribute

### 1. Reporting Issues
- Use the [GitHub Issues](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/issues) page
- Provide clear reproduction steps
- Include your environment details (OS, Bash version, GitHub CLI version)
- Use the provided issue templates

### 2. Suggesting Features
- Use [GitHub Discussions](https://github.com/lmaiacosta/say-goodbye-to-your-local-env/discussions)
- Describe the use case and benefit
- Provide examples of how it would work

### 3. Code Contributions

#### Process
1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes
4. **Test** thoroughly
5. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
6. **Push** to your branch: `git push origin feature/amazing-feature`
7. **Create** a Pull Request

#### Code Standards
- Follow existing code style and patterns
- Use descriptive variable names
- Add comments for complex logic
- Test with different environments and edge cases
- Follow shellcheck recommendations

## 🧪 Testing

### Manual Testing
```bash
# Test all modes
./byebyenv.sh --dry-run
./byebyenv.sh production --auto --dry-run
./byebyenv.sh staging --dry-run

# Test edge cases
./byebyenv.sh --help
./byebyenv.sh --version
./byebyenv.sh invalid-environment
```

### Automated Testing
We welcome contributions to add automated testing:
- Unit tests for classification logic
- Integration tests with mock GitHub CLI
- End-to-end testing scenarios

## 📝 Code Style

### Shell Script Best Practices
- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Quote variables: `"$VARIABLE"`
- Use meaningful function names
- Add error handling for all external commands

### Example Function
```bash
# Good example
upload_secret() {
    local name="$1"
    local value="$2"

    # Validate inputs
    if [ -z "$name" ] || [ -z "$value" ]; then
        echo -e "${RED}❌ Invalid parameters${NC}"
        return 1
    fi

    # Implementation with error handling
    if echo "$value" | gh secret set "$name" --repo "$REPO" 2>/dev/null; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}
```

## 🎯 Priority Areas

We especially welcome contributions in these areas:

### High Priority
- **Multi-repository support** - Upload to multiple repos
- **Configuration file** - `.envaultrc` for settings
- **Backup/restore functionality** - Download existing secrets
- **Better error handling** - More robust error messages

### Medium Priority
- **Template system** - Predefined environment configurations
- **GitLab/Bitbucket support** - Other platform integrations
- **Encryption at rest** - Local file encryption
- **Progress bars** - Visual progress indicators

### Documentation
- **Wiki pages** - Detailed usage examples
- **Video tutorials** - Screen recordings of common workflows
- **Blog posts** - Use case studies and best practices
- **Translations** - Multi-language support

## 🚦 Pull Request Process

### Before Submitting
1. **Test thoroughly** on different environments
2. **Update documentation** if needed
3. **Add/update examples** in README if applicable
4. **Check shellcheck** warnings: `shellcheck byebyenv.sh`

### PR Template
Please include:
- **Description** of changes
- **Testing performed** (manual/automated)
- **Breaking changes** (if any)
- **Related issues** (if applicable)

### Review Process
1. **Automated checks** will run
2. **Maintainer review** within 48 hours
3. **Discussion** and iteration if needed
4. **Merge** after approval

## 🏷️ Release Process

### Versioning
We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes

### Release Checklist
- [ ] Update version in script
- [ ] Update CHANGELOG.md
- [ ] Create GitHub release
- [ ] Update documentation
- [ ] Announce in discussions

## 💬 Communication

### Channels
- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and ideas
- **Pull Requests** - Code review and discussion

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow the [Contributor Covenant](https://www.contributor-covenant.org/)

## 🎉 Recognition

Contributors will be:
- **Listed** in README.md
- **Mentioned** in release notes
- **Invited** to join maintainer team (for significant contributions)

## 📞 Getting Help

- **Documentation**: Check README.md first
- **Search**: Look through existing issues and discussions
- **Ask**: Create a new discussion if you can't find answers

---

Thank you for making Envault better! 🚀