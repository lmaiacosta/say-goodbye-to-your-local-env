#!/bin/bash

# Envault Repository Setup Script
# This script helps you create and configure a new Envault repository

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Envault Repository Setup${NC}"
echo "================================="

# Check prerequisites
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not installed${NC}"
    echo "Install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Get repository information
echo -e "\n${YELLOW}📝 Repository Configuration${NC}"
read -p "Repository name (default: envault): " repo_name
repo_name=${repo_name:-envault}

read -p "Description (default: Interactive GitHub Secrets & Variables Management Tool): " description
description=${description:-"Interactive GitHub Secrets & Variables Management Tool"}

read -p "Make repository public? (y/N): " public
if [[ "$public" =~ ^[Yy]$ ]]; then
    visibility="public"
else
    visibility="private"
fi

echo -e "\n${BLUE}📊 Repository Details:${NC}"
echo "  Name: $repo_name"
echo "  Description: $description"
echo "  Visibility: $visibility"
echo ""

read -p "Continue? (Y/n): " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Create GitHub repository
echo -e "\n${YELLOW}🏗️  Creating GitHub repository...${NC}"
if [ "$visibility" = "public" ]; then
    gh repo create "$repo_name" --description "$description" --public
else
    gh repo create "$repo_name" --description "$description" --private
fi

# Initialize git repository
echo -e "${YELLOW}📁 Initializing local repository...${NC}"
git init
git add .
git commit -m "Initial commit: Envault v1.0.0

✨ Features:
- Interactive environment variable classification
- Smart secret vs variable detection
- Multi-environment support (production, staging, development)
- Dry-run mode for safe previewing
- Auto-mode for batch processing
- Full GitHub CLI integration

🔧 Usage:
- ./byebyenv.sh (interactive mode)
- ./byebyenv.sh production --auto
- ./byebyenv.sh staging --dry-run
"

# Set remote and push
username=$(gh api user --jq .login)
git remote add origin "https://github.com/$username/$repo_name.git"
git branch -M main
git push -u origin main

echo -e "\n${GREEN}🎉 Repository created successfully!${NC}"
echo -e "${BLUE}🔗 Repository: https://github.com/$username/$repo_name${NC}"
echo -e "${BLUE}📖 Clone command: git clone https://github.com/$username/$repo_name.git${NC}"

# Setup instructions
echo -e "\n${YELLOW}📋 Next Steps:${NC}"
echo "1. Update the REPO variable in byebyenv.sh:"
echo -e "   ${BLUE}REPO=\"$username/$repo_name\"${NC}"
echo ""
echo "2. Create your environment files:"
echo "   touch .env.production .env.staging .env.development"
echo ""
echo "3. Test the script:"
echo "   ./byebyenv.sh --dry-run"
echo ""
echo "4. Share with the community!"

echo -e "\n${GREEN}✅ Setup complete!${NC}"