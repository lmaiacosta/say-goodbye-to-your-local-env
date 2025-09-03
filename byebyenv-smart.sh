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

# Configuration (will be auto-detected)
REPO=""
ENVIRONMENT=""
DRY_RUN=false
AUTO_MODE=false

# Show version
show_version() {
    echo -e "${PURPLE}🚀 Envault v$VERSION${NC}"
    echo "Interactive GitHub Secrets & Variables Management Tool"
    echo "Say NO to lazy work! 🔐✨"
    echo "Repository: https://github.com/lmaiacosta/say-goodbye-to-your-local-env"
}

# Show help function
show_help() {
    show_version
    echo ""
    echo "Usage: $0 [environment] [--auto] [--dry-run] [--version] [--help]"
    echo ""
    echo "🌍 Environments:"
    echo "  production   - Uses system environment variables (no prefix)"
    echo "  staging      - Uses system environment variables (STAGING_ prefix)"
    echo "  development  - Uses system environment variables (DEVELOPMENT_ prefix)"
    echo ""
    echo "🎯 Modes:"
    echo "  [no flags]   - Interactive mode: asks you about each variable (RECOMMENDED)"
    echo "  --auto       - Auto mode: uses smart guessing for secret vs variable"
    echo "  --dry-run    - Preview only, no actual uploads"
    echo "  --version    - Show version information"
    echo "  --help       - Show this help message"
    echo ""
    echo "💡 What happens automatically:"
    echo "  ✅ Detects if you're logged into GitHub CLI"
    echo "  ✅ Shows your repositories to choose from"
    echo "  ✅ Reads environment variables from your system"
    echo "  ✅ No hardcoded repository names needed!"
    echo ""
    echo "🔧 If not logged in:"
    echo "  ✅ Automatically runs setup.sh to help you get started"
    echo ""
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

# Check GitHub CLI installation
if ! command -v gh &> /dev/null; then
    echo -e "\n${RED}❌ GitHub CLI not installed${NC}"
    echo "Install: https://cli.github.com/"
    echo ""
    echo -e "${YELLOW}🛠️  Running setup to help you...${NC}"
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    else
        echo -e "${RED}❌ setup.sh not found${NC}"
        echo "Please install GitHub CLI manually"
    fi
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &> /dev/null 2>&1; then
    echo -e "\n${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo -e "${YELLOW}🛠️  Running setup to help you get authenticated...${NC}"
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    else
        echo "Please run: gh auth login"
    fi
    exit 1
fi

# Get current user
USERNAME=$(gh api user --jq .login 2>/dev/null || echo "unknown")
echo -e "${GREEN}✅ Logged in as: ${BLUE}$USERNAME${NC}"

# Interactive repository selection
select_repository() {
    echo -e "\n${YELLOW}📂 Select target repository:${NC}"
    echo "Fetching your repositories..."

    # Get repositories with error handling
    local repos
    if ! repos=$(gh repo list --limit 20 --json name,owner 2>/dev/null); then
        echo -e "${RED}❌ Failed to fetch repositories${NC}"
        read -p "Enter repository manually (owner/repo): " REPO
        return
    fi

    # Parse repositories
    local repo_list=()
    while IFS= read -r line; do
        if [[ "$line" =~ \"name\":\"([^\"]+)\".*\"login\":\"([^\"]+)\" ]]; then
            repo_list+=("${BASH_REMATCH[2]}/${BASH_REMATCH[1]}")
        fi
    done <<< "$repos"

    if [ ${#repo_list[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No repositories found${NC}"
        read -p "Enter repository manually (owner/repo): " REPO
        return
    fi

    # Display repositories
    local i=1
    for repo in "${repo_list[@]}"; do
        echo "$i) $repo"
        ((i++))
    done
    echo "$i) Enter manually"

    while true; do
        read -p "Choose repository (1-$i): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#repo_list[@]} ]; then
            REPO="${repo_list[$((choice-1))]}"
            break
        elif [ "$choice" -eq $i ]; then
            read -p "Enter repository manually (owner/repo): " REPO
            break
        else
            echo "Invalid choice. Try again."
        fi
    done
}

# Select repository
select_repository
echo -e "${GREEN}🎯 Selected repository: ${BLUE}$REPO${NC}"

# Interactive environment selection if not provided
if [ -z "$ENVIRONMENT" ]; then
    echo -e "\n${YELLOW}🌍 Select target environment:${NC}"
    echo "1) production   (no prefix, reads system environment variables)"
    echo "2) staging      (STAGING_ prefix, reads system environment variables)"
    echo "3) development  (DEVELOPMENT_ prefix, reads system environment variables)"
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

# Smart classification function
is_secret_smart() {
    local name="$1"
    [[ "$name" =~ ^.*_(PASSWORD|SECRET|KEY|TOKEN|PRIVATE_KEY|CREDENTIAL|AUTH).*$ ]] || \
    [[ "$name" =~ ^(DATABASE_PASSWORD|DATABASE_USER|MYSQL_PASSWORD|MYSQL_USER)$ ]] || \
    [[ "$name" =~ ^(NEXTAUTH_SECRET|JWT_SECRET|ENCRYPTION_KEY)$ ]] || \
    [[ "$name" =~ ^.*API_KEY.*$ ]] || \
    [[ "$name" =~ ^(KEYCLOAK_CLIENT_SECRET|OAUTH_CLIENT_SECRET|OPENAI_API_KEY)$ ]] || \
    [[ "$name" =~ ^.*_(CLIENT_SECRET|ACCESS_KEY|PRIVATE).*$ ]]
}

# Interactive classification function
ask_classification() {
    local name="$1"
    local value="$2"
    local smart_guess=""

    if is_secret_smart "$name"; then
        smart_guess="SECRET (recommended)"
    else
        smart_guess="VARIABLE (recommended)"
    fi

    echo -e "\n${CYAN}🤔 Classify: ${YELLOW}$name${NC}"
    echo "   Value preview: ${value:0:20}$([ ${#value} -gt 20 ] && echo "...")"
    echo "   Smart guess: $smart_guess"
    echo "   1) SECRET (encrypted, hidden from logs)"
    echo "   2) VARIABLE (public config, visible in logs)"
    echo "   3) SKIP (don't upload this)"

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

# Read environment variables from system
echo -e "\n${YELLOW}🔍 Reading environment variables from system...${NC}"

# Collect environment variables with common patterns
declare -A VARIABLES
total_count=0

# Common environment variable patterns for different environments
ENV_PATTERNS=(
    "DATABASE_"
    "DB_"
    "MYSQL_"
    "POSTGRES_"
    "REDIS_"
    "API_"
    "OPENAI_"
    "GOOGLE_"
    "AWS_"
    "AZURE_"
    "STRIPE_"
    "NEXTAUTH_"
    "JWT_"
    "NODE_ENV"
    "NEXT_PUBLIC_"
    "VERCEL_"
    "PORT"
    "HOST"
    "URL"
    "ENCRYPTION_"
    "SECRET_"
    "KEY_"
    "TOKEN_"
    "CLIENT_"
    "OAUTH_"
    "KEYCLOAK_"
    "AUTH_"
    "SENTRY_"
    "LOG_"
    "DEBUG"
    "ENABLE_"
    "FEATURE_"
)

echo -e "${BLUE}📊 Scanning system environment variables...${NC}"

# Scan environment variables
for pattern in "${ENV_PATTERNS[@]}"; do
    while IFS='=' read -r name value; do
        if [[ "$name" == *"$pattern"* ]] && [[ -n "$value" ]]; then
            # Skip common system variables that shouldn't be uploaded
            if [[ ! "$name" =~ ^(PATH|HOME|USER|SHELL|PWD|OLDPWD|TERM|LANG|LC_|XDG_|DISPLAY|SESSION|DESKTOP).*$ ]]; then
                VARIABLES["$name"]="$value"
                ((total_count++))
            fi
        fi
    done < <(env | grep -i "$pattern" 2>/dev/null || true)
done

# Also check for common variable names without patterns
COMMON_VARS=(
    "NODE_ENV"
    "PORT"
    "HOST"
    "URL"
    "DEBUG"
)

for var in "${COMMON_VARS[@]}"; do
    if [[ -n "${!var}" ]]; then
        VARIABLES["$var"]="${!var}"
        ((total_count++))
    fi
done

echo -e "\n${GREEN}📊 Found $total_count environment variables to process${NC}"

if [ $total_count -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No relevant environment variables found${NC}"
    echo -e "${BLUE}💡 Make sure you have environment variables set in your system${NC}"
    echo -e "${BLUE}💡 Example: export DATABASE_PASSWORD=mysecret${NC}"
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
        ask_classification "$name" "$value"
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
    gh secret list --repo "$REPO" 2>/dev/null | head -5 || echo "No secrets found"

    echo -e "\n${YELLOW}📝 Current variables (first 5):${NC}"
    gh variable list --repo "$REPO" 2>/dev/null | head -5 || echo "No variables found"
else
    echo -e "\n${BLUE}💡 Run without --dry-run to actually upload${NC}"
fi

echo -e "\n${GREEN}✅ Done!${NC}"
echo -e "${PURPLE}🧠 You were smart about your secrets - no lazy work here!${NC}"
echo -e "${BLUE}💙 Thank you for using Envault!${NC}"
echo -e "${CYAN}🔮 Coming soon: BitBucket support!${NC}"
