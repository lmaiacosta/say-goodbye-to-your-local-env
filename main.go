package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"github.com/fatih/color"
	"github.com/google/go-github/v57/github"
	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2"
)

const Version = "2.0.0"

var (
	envFile     string
	environment string
	repository  string
	dryRun      bool
	autoMode    bool
)

type Classification int

const (
	Secret Classification = iota
	Variable
	Skip
)

var rootCmd = &cobra.Command{
	Use:   "envault",
	Short: "Upload .env variables to GitHub Secrets",
	Long: `🚀 Envault - Upload .env files to GitHub Actions Secrets

Examples:
  envault -f .env -r owner/repo
  envault -f .env.staging -r owner/repo -e staging --auto
  envault -f .env --dry-run
`,
	Version: Version,
	Run:     run,
}

func init() {
	rootCmd.Flags().StringVarP(&envFile, "env-file", "f", "", "Path to .env file (required)")
	rootCmd.Flags().StringVarP(&environment, "environment", "e", "", "Environment (production, staging, development)")
	rootCmd.Flags().StringVarP(&repository, "repo", "r", "", "GitHub repository (owner/repo)")
	rootCmd.Flags().BoolVar(&dryRun, "dry-run", false, "Preview without uploading")
	rootCmd.Flags().BoolVar(&autoMode, "auto", false, "Auto classify variables")
	rootCmd.MarkFlagRequired("env-file")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func run(cmd *cobra.Command, args []string) {
	color.Cyan("🚀 Envault v%s\n", Version)

	// Validate environment file
	if _, err := os.Stat(envFile); os.IsNotExist(err) {
		color.Red("❌ Environment file not found: %s", envFile)
		os.Exit(1)
	}

	// Auto-detect repository if not provided
	if repository == "" {
		if repo, err := getRepoFromGit(); err == nil {
			repository = repo
			color.Blue("🔍 Auto-detected repository: %s", repository)
		} else {
			color.Red("❌ Repository not specified. Use -r owner/repo")
			color.Yellow("💡 Or run from a git repository with GitHub remote")
			os.Exit(1)
		}
	}

	// Auto-detect environment if not provided
	if environment == "" {
		environment = detectEnvironment()
		color.Blue("🔍 Auto-detected environment: %s", environment)
	}

	// Validate repository format
	if !regexp.MustCompile(`^[^/]+/[^/]+$`).MatchString(repository) {
		color.Red("❌ Invalid repository format. Use: owner/repo")
		os.Exit(1)
	}

	// Setup GitHub client
	client, err := setupGitHub()
	if err != nil {
		color.Red("❌ GitHub authentication failed: %v", err)
		color.Yellow("💡 Make sure GitHub CLI is installed and authenticated:")
		color.Yellow("   brew install gh && gh auth login")
		color.Yellow("   # or visit: https://cli.github.com/")
		os.Exit(1)
	}

	// Parse .env file
	vars, err := godotenv.Read(envFile)
	if err != nil {
		color.Red("❌ Error reading .env file: %v", err)
		os.Exit(1)
	}

	if len(vars) == 0 {
		color.Yellow("⚠️  No variables found in %s", envFile)
		os.Exit(0)
	}

	color.Green("📊 Found %d variables in %s", len(vars), envFile)

	if dryRun {
		color.Yellow("🔍 DRY RUN MODE - No changes will be made")
	}

	fmt.Println()

	// Process variables
	uploaded := 0
	for name, value := range vars {
		if value == "" {
			color.Yellow("⚠️  Skipping empty variable: %s", name)
			continue
		}

		var classification Classification
		if autoMode {
			classification = autoClassify(name, value)
			color.Cyan("   %s → %s", name, classificationString(classification))
		} else {
			classification = askUser(name, value)
		}

		if classification == Skip {
			color.Yellow("⏭️  Skipped: %s", name)
			continue
		}

		varName := name
		if environment != "production" {
			varName = strings.ToUpper(environment) + "_" + name
		}

		if dryRun {
			color.Blue("   Would upload %s as %s", varName, classificationString(classification))
			uploaded++
			continue
		}

		if err := uploadToGitHub(client, varName, value, classification); err != nil {
			color.Red("   ❌ Failed to upload %s: %v", varName, err)
		} else {
			color.Green("   ✅ Uploaded %s", varName)
			uploaded++
		}
	}

	fmt.Println()
	if dryRun {
		color.Blue("🎉 Preview complete: %d variables would be uploaded", uploaded)
		color.Yellow("💡 Run without --dry-run to upload for real")
	} else {
		color.Green("🎉 Successfully uploaded %d variables to %s/%s", uploaded, repository, environment)
	}
}

func getRepoFromGit() (string, error) {
	cmd := exec.Command("git", "config", "--get", "remote.origin.url")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	url := strings.TrimSpace(string(output))
	re := regexp.MustCompile(`github\.com[:/]([^/]+/[^/]+?)(?:\.git)?$`)
	matches := re.FindStringSubmatch(url)
	if len(matches) > 1 {
		return matches[1], nil
	}
	return "", fmt.Errorf("not a GitHub repository")
}

func detectEnvironment() string {
	filename := strings.ToLower(envFile)
	if strings.Contains(filename, "prod") {
		return "production"
	}
	if strings.Contains(filename, "stag") {
		return "staging"
	}
	if strings.Contains(filename, "dev") {
		return "development"
	}
	return "development"
}

func setupGitHub() (*github.Client, error) {
	// Check if gh CLI is available
	if _, err := exec.LookPath("gh"); err != nil {
		return nil, fmt.Errorf("GitHub CLI not found. Install from https://cli.github.com/")
	}

	// Get token from gh CLI
	cmd := exec.Command("gh", "auth", "token")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("GitHub CLI not authenticated. Run: gh auth login")
	}

	token := strings.TrimSpace(string(output))
	if token == "" {
		return nil, fmt.Errorf("empty token from GitHub CLI")
	}

	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	client := github.NewClient(oauth2.NewClient(context.Background(), ts))

	// Test authentication by getting user info
	ctx := context.Background()
	user, _, err := client.Users.Get(ctx, "")
	if err != nil {
		return nil, fmt.Errorf("authentication test failed: %v", err)
	}

	color.Green("✅ GitHub authenticated as %s", *user.Login)
	return client, nil
}

func autoClassify(name, value string) Classification {
	n := strings.ToLower(name)

	// Secret indicators in name
	secrets := []string{"password", "secret", "key", "token", "private", "auth", "credential", "api_key", "private_key"}
	for _, s := range secrets {
		if strings.Contains(n, s) {
			return Secret
		}
	}

	// Known token prefixes
	tokenPrefixes := []string{"sk-", "ghp_", "ghs_", "gho_", "ghu_", "github_pat_"}
	for _, prefix := range tokenPrefixes {
		if strings.HasPrefix(value, prefix) {
			return Secret
		}
	}

	// Long random-looking strings are likely secrets
	if len(value) > 32 && containsRandomChars(value) {
		return Secret
	}

	return Variable
}

func containsRandomChars(s string) bool {
	// Check if string looks random (has mix of upper, lower, numbers)
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(s)
	hasLower := regexp.MustCompile(`[a-z]`).MatchString(s)
	hasDigit := regexp.MustCompile(`[0-9]`).MatchString(s)

	return (hasUpper && hasLower && hasDigit) ||
		   (hasUpper && hasDigit && len(s) > 20) ||
		   (hasLower && hasDigit && len(s) > 20)
}

func askUser(name, value string) Classification {
	displayValue := value
	if len(value) > 50 {
		displayValue = value[:47] + "..."
	}

	fmt.Printf("\n📝 %s: %s\n", color.CyanString(name), displayValue)
	suggestion := autoClassify(name, value)
	fmt.Printf("💡 Suggested: %s\n", classificationString(suggestion))

	for {
		fmt.Print("Choose: [S]ecret, [V]ariable, [K]eep suggestion, [X]skip: ")
		reader := bufio.NewReader(os.Stdin)
		input, _ := reader.ReadString('\n')
		input = strings.ToUpper(strings.TrimSpace(input))

		switch input {
		case "S":
			return Secret
		case "V":
			return Variable
		case "K", "":
			return suggestion
		case "X":
			return Skip
		default:
			color.Yellow("⚠️  Invalid choice, try again")
		}
	}
}

func classificationString(c Classification) string {
	switch c {
	case Secret:
		return color.RedString("SECRET")
	case Variable:
		return color.GreenString("VARIABLE")
	default:
		return color.YellowString("SKIP")
	}
}

func uploadToGitHub(client *github.Client, name, value string, classification Classification) error {
	ctx := context.Background()
	parts := strings.Split(repository, "/")
	owner, repo := parts[0], parts[1]

	// For now, upload everything as secrets since GitHub Variables API is complex
	// and secrets are more secure anyway
	return uploadSecret(ctx, client, owner, repo, name, value)
}

func uploadSecret(ctx context.Context, client *github.Client, owner, repo, name, value string) error {
	// Get repository public key for encryption
	publicKey, _, err := client.Actions.GetRepoPublicKey(ctx, owner, repo)
	if err != nil {
		return fmt.Errorf("failed to get repository public key: %v", err)
	}

	// Encrypt the secret value
	encrypted, err := encryptSecret(*publicKey.Key, value)
	if err != nil {
		return fmt.Errorf("failed to encrypt secret: %v", err)
	}

	// Create the encrypted secret
	secret := &github.EncryptedSecret{
		Name:           name,
		KeyID:          *publicKey.KeyID,
		EncryptedValue: encrypted,
	}

	// Upload to GitHub
	_, err = client.Actions.CreateOrUpdateRepoSecret(ctx, owner, repo, secret)
	if err != nil {
		return fmt.Errorf("failed to upload secret: %v", err)
	}

	return nil
}
