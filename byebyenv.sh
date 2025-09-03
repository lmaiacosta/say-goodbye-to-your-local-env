#!/bin/bash

# 🚀 Envault - Interactive GitHub Secrets & Variables Management Tool
# Say NO to lazy work! This tool makes you THINK about your secrets while automating the boring parts.
# Repository: https://github.com/lmaiacosta/say-goodbye-to-your-local-env
# License: MIT

set -e

# Version
VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration - UPDATE THIS FOR YOUR REPOSITORY
REPO="yourusername/yourrepo"  # ⚠️  CHANGE THIS TO YOUR REPOSITORY
ENVIRONMENT=""
DRY_RUN=false
AUTO_MODE=false

# Show version
show_version() {
    echo -e "${PURPLE}🚀 Envault v$VERSION${NC}"
    echo "Interactive GitHub Secrets & Variables Management Tool"
    echo "Say NO to lazy work! 🔐✨"
    echo "Repository: https://github.com/lmaiacosta/say-goodbye-to-your-local-env "
}

# Show help function
show_help() {
    show_version
    echo ""
    echo "Usage: $0 [environment] [--auto] [--dry-run] [--version] [--help]"
    echo ""
    echo "🌍 Environments:"
    echo "  production   - Uses .env.production + .env.local (no prefix)"
    echo "  staging      - Uses .env.staging + .env.local (STAGING_ prefix)"
    echo "  development  - Uses .env.development + .env.local (DEVELOPMENT_ prefix)"
    echo ""
    echo "🎯 Modes:"
    echo "  [no flags]   - Interactive mode: asks you about each variable (RECOMMENDED)"
    echo "  --auto       - Auto mode: uses smart guessing for secret vs variable"
    echo "  --dry-run    - Preview only, no actual uploads"
    echo "  --version    - Show version information"
    echo "  --help       - Show this help message"
    echo ""
    echo "💡 What happens if you don't specify environment:"
    echo "  ✅ Interactive menu asks you to choose"
    echo "  ✅ You have full control over every decision"
    echo "  ✅ No lazy work - you think about each variable!"
    echo ""
    echo "📝 Examples:"
    echo "  $0                          # Interactive: choose environment and each variable"
    echo "  $0 production --auto        # Auto upload production with smart guessing"
    echo "  $0 staging --dry-run        # Preview staging upload"
    echo ""
    echo "⚠️  IMPORTANT: Update the REPO variable in this script before using!"
    echo "   Current setting: $REPO"
    echo ""
    echo "🔮 Coming soon: BitBucket support!"
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --auto)
            AUTO_MODE=true
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        production|staging|development)
            ENVIRONMENT="$arg"
            ;;
    esac
done

show_version
echo -e "${BLUE}🎯 Repository: $REPO${NC}"

# Check if repository is configured
if [[ "$REPO" == "yourusername/yourrepo" ]]; then
    echo -e "\n${RED}🚨 REPOSITORY NOT CONFIGURED${NC}"
    echo -e "${YELLOW}Please update the REPO variable in this script:${NC}"
    echo -e "${BLUE}   REPO=\"yourusername/yourrepo\"${NC}"
    echo -e "${BLUE}   ↓${NC}"
    echo -e "${GREEN}   REPO=\"your-github-username/your-repository-name\"${NC}"
    echo ""
    echo -e "${PURPLE}💡 This is NOT lazy work - it's being smart about your secrets!${NC}"
    exit 1
fi

# Interactive environment selection if not provided
if [ -z "$ENVIRONMENT" ]; then
    echo -e "\n${YELLOW}🌍 Select target environment:${NC}"
    echo "1) production   (no prefix, uses .env.production + .env.local)"
    echo "2) staging      (STAGING_ prefix, uses .env.staging + .env.local)"
    echo "3) development  (DEVELOPMENT_ prefix, uses .env.development + .env.local)"
    echo ""
    read -p "Choose environment (1-3): " choice

    case $choice in
        1) ENVIRONMENT="production" ;;
        2) ENVIRONMENT="staging" ;;
        3) ENVIRONMENT="development" ;;
        *) echo -e "${RED}❌ Invalid choice${NC}"; exit 1 ;;
    esac
fi

echo -e "${GREEN}🌍 Environment: $ENVIRONMENT${NC}"

if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${GREEN}📝 Variable naming: No prefix${NC}"
else
    echo -e "${YELLOW}📝 Variable naming: ${ENVIRONMENT^^}_ prefix${NC}"
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
fi

if [ "$AUTO_MODE" = true ]; then
    echo -e "${CYAN}🤖 AUTO MODE - Using smart classification${NC}"
    echo -e "${YELLOW}💭 (Still smarter than lazy scripts!)${NC}"
else
    echo -e "${CYAN}👤 INTERACTIVE MODE - You decide each variable${NC}"
    echo -e "${GREEN}🧠 This is the smart way - no lazy work here!${NC}"
fi

echo "=================================================="

# Prerequisites check
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

echo -e "${GREEN}✅ Prerequisites met${NC}"

# Smart classification function
is_secret_smart() {
    local name="$1"
    [[ "$name" =~ ^.*_(PASSWORD|SECRET|KEY|TOKEN|PRIVATE_KEY|CREDENTIAL|AUTH).*$ ]] || \
    [[ "$name" =~ ^(DATABASE_PASSWORD|DATABASE_USER|MYSQL_PASSWORD|MYSQL_USER)$ ]] || \
    [[ "$name" =~ ^(NEXTAUTH_SECRET|JWT_SECRET|ENCRYPTION_KEY)$ ]] || \
    [[ "$name" =~ ^.*API_KEY.*$ ]] || \
    [[ "$name" =~ ^(KEYCLOAK_CLIENT_SECRET|OAUTH_CLIENT_SECRET|OPENAI_API_KEY)$ ]]
}

# Interactive classification function
ask_classification() {
    local name="$1"
    local smart_guess=""

    if is_secret_smart "$name"; then
        smart_guess="SECRET (recommended)"
    else
        smart_guess="VARIABLE (recommended)"
    fi

    echo -e "\n${CYAN}🤔 Classify: ${YELLOW}$name${NC}"
    echo "   🧠 Smart guess: $smart_guess"
    echo "   1) 🔐 SECRET (encrypted, hidden from logs)"
    echo "   2) 📝 VARIABLE (public config, visible in logs)"
    echo "   3) ⏭️  SKIP (don't upload this)"

    while true; do
        read -p "   Choose (1/2/3) or press Enter for smart guess: " choice
        case $choice in
            1) return 0 ;; # SECRET
            2) return 1 ;; # VARIABLE
            3) return 2 ;; # SKIP
            "")
                if is_secret_smart "$name"; then
                    return 0  # SECRET
                else
                    return 1  # VARIABLE
                fi
                ;;
            *) echo "   Invalid choice. Try again." ;;
        esac
    done
}

# Upload functions
upload_secret() {
    local name="$1"
    local value="$2"

    if [ "$ENVIRONMENT" != "production" ]; then
        name="${ENVIRONMENT^^}_${name}"
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}🔐 [DRY RUN] Would upload SECRET: $name (${#value} chars)${NC}"
        return 0
    fi

    echo -e "${BLUE}🔐 Uploading SECRET: $name...${NC}"
    if echo "$value" | gh secret set "$name" --repo "$REPO" 2>/dev/null; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

upload_variable() {
    local name="$1"
    local value="$2"

    if [ "$ENVIRONMENT" != "production" ]; then
        name="${ENVIRONMENT^^}_${name}"
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}📝 [DRY RUN] Would set VARIABLE: $name = $value${NC}"
        return 0
    fi

    echo -e "${BLUE}📝 Setting VARIABLE: $name = $value${NC}"
    if gh variable set "$name" --body "$value" --repo "$REPO" 2>/dev/null; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Process environment files
ENV_FILES=()
case "$ENVIRONMENT" in
    "production")
        ENV_FILES+=(".env.production" ".env.local")
        ;;
    "staging")
        ENV_FILES+=(".env.staging" ".env.local")
        ;;
    "development")
        ENV_FILES+=(".env.development" ".env.local")
        ;;
esac

echo -e "\n${YELLOW}📂 Environment files for $ENVIRONMENT:${NC}"
for file in "${ENV_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "   ✅ $file"
    else
        echo -e "   ❌ $file (not found)"
    fi
done

# Collect all variables first
declare -A VARIABLES
total_count=0

for env_file in "${ENV_FILES[@]}"; do
    if [ -f "$env_file" ]; then
        echo -e "\n${BLUE}📄 Reading: $env_file${NC}"

        while IFS= read -r line || [ -n "$line" ]; do
            # Skip comments and empty lines
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

            # Extract name=value
            if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
                name="${BASH_REMATCH[1]}"
                value="${BASH_REMATCH[2]}"
                value=$(echo "$value" | sed 's/^["'"'"']//;s/["'"'"']$//')

                # Skip empty values
                if [ -n "$value" ]; then
                    VARIABLES["$name"]="$value"
                    ((total_count++))
                fi
            fi
        done < "$env_file"
    fi
done

echo -e "\n${GREEN}📊 Found $total_count variables to process${NC}"

if [ $total_count -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No variables found to upload${NC}"
    echo -e "${BLUE}💡 Create your .env files and try again!${NC}"
    exit 0
fi

# Process each variable
uploaded_count=0
skipped_count=0

echo -e "\n${PURPLE}🚀 Time to be smart about your secrets!${NC}"
if [ "$AUTO_MODE" = false ]; then
    echo -e "${GREEN}💭 Think about each variable - no lazy work here!${NC}"
fi

for name in "${!VARIABLES[@]}"; do
    value="${VARIABLES[$name]}"

    if [ "$AUTO_MODE" = true ]; then
        # Auto mode: use smart classification
        if is_secret_smart "$name"; then
            upload_secret "$name" "$value" && ((uploaded_count++))
        else
            upload_variable "$name" "$value" && ((uploaded_count++))
        fi
    else
        # Interactive mode: ask user
        ask_classification "$name"
        case $? in
            0) upload_secret "$name" "$value" && ((uploaded_count++)) ;;
            1) upload_variable "$name" "$value" && ((uploaded_count++)) ;;
            2) echo -e "${YELLOW}⏭️  Skipping $name${NC}"; ((skipped_count++)) ;;
        esac
    fi
done

# Set system variables
echo -e "\n${YELLOW}⚙️  System configuration...${NC}"
upload_variable "NODE_ENV" "$ENVIRONMENT" && ((uploaded_count++))

# Summary
echo -e "\n${GREEN}🎉 Upload completed for $ENVIRONMENT!${NC}"
echo -e "${GREEN}📊 Uploaded: $uploaded_count${NC}"
if [ $skipped_count -gt 0 ]; then
    echo -e "${YELLOW}📊 Skipped: $skipped_count${NC}"
fi

if [ "$DRY_RUN" = false ]; then
    echo -e "\n${BLUE}🔗 View secrets: https://github.com/$REPO/settings/secrets/actions${NC}"
    echo -e "${BLUE}🔗 View variables: https://github.com/$REPO/settings/variables/actions${NC}"

    echo -e "\n${YELLOW}📋 Current secrets (first 5):${NC}"
    gh secret list --repo "$REPO" 2>/dev/null | head -5

    echo -e "\n${YELLOW}📝 Current variables (first 5):${NC}"
    gh variable list --repo "$REPO" 2>/dev/null | head -5
else
    echo -e "\n${BLUE}💡 Run without --dry-run to actually upload${NC}"
fi

echo -e "\n${GREEN}✅ Done!${NC}"
echo -e "${PURPLE}🧠 You were smart about your secrets - no lazy work here!${NC}"
echo -e "${BLUE}💙 Thank you for using Envault!${NC}"
echo -e "${CYAN}🔮 Coming soon: BitBucket support!${NC}"
