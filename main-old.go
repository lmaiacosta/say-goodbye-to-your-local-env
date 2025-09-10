package main

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"

	"github.com/fatih/color"
	"github.com/google/go-github/v57/github"
	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2"
)

const Version = "2.0.0"

var (
	// Colors
	red    = color.New(color.FgRed)
	green  = color.New(color.FgGreen)
	yellow = color.New(color.FgYellow)
	blue   = color.New(color.FgBlue)
	purple = color.New(color.FgMagenta)
	cyan   = color.New(color.FgCyan)

	// Flags
	envFile     string
	environment string
	repository  string
	dryRun      bool
	autoMode    bool
	verbose     bool
)

type EnvVar struct {
	Name   string
	Value  string
	Source string
}

type Classification int

const (
	Secret Classification = iota
	Variable
	Skip
)

func (c Classification) String() string {
	switch c {
	case Secret:
		return "SECRET"
	case Variable:
		return "VARIABLE"
	case Skip:
		return "SKIP"
	default:
		return "UNKNOWN"
	}
}

var rootCmd = &cobra.Command{
	Use:   "envault",
	Short: "Interactive GitHub Secrets & Variables Management Tool",
	Long: `🚀 Envault - Say NO to lazy work!

Upload environment variables to GitHub Secrets and Variables with smart classification.
This tool makes you THINK about your secrets while automating the boring parts.

Examples:
  envault --env-file .env.production --repo owner/repo --environment production
  envault --env-file .env.staging --repo owner/repo --environment staging --auto
  envault --env-file .env --repo owner/repo --dry-run
`,
	Version: Version,
	Run:     runEnvault,
}

func init() {
	rootCmd.Flags().StringVarP(&envFile, "env-file", "f", "", "Path to .env file (required)")
	rootCmd.Flags().StringVarP(&environment, "environment", "e", "", "Target environment (production, staging, development)")
	rootCmd.Flags().StringVarP(&repository, "repo", "r", "", "GitHub repository (owner/repo format)")
	rootCmd.Flags().BoolVar(&dryRun, "dry-run", false, "Preview changes without uploading")
	rootCmd.Flags().BoolVar(&autoMode, "auto", false, "Use automatic classification")
	rootCmd.Flags().BoolVarP(&verbose, "verbose", "v", false, "Verbose output")

	rootCmd.MarkFlagRequired("env-file")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func runEnvault(cmd *cobra.Command, args []string) {
	printHeader()

	// Validate inputs
	if err := validateInputs(); err != nil {
		red.Printf("❌ Error: %v\n", err)
		os.Exit(1)
	}

	// Check GitHub authentication
	client, err := setupGitHubClient()
	if err != nil {
		red.Printf("❌ GitHub authentication error: %v\n", err)
		os.Exit(1)
	}

	// Parse environment file
	variables, err := parseEnvFile(envFile)
	if err != nil {
		red.Printf("❌ Error parsing env file: %v\n", err)
		os.Exit(1)
	}

	if len(variables) == 0 {
		yellow.Println("⚠️  No variables found in environment file")
		os.Exit(0)
	}

	green.Printf("📊 Found %d variables to process\n", len(variables))

	// Process variables
	uploaded, skipped := processVariables(client, variables)

	// Summary
	printSummary(uploaded, skipped)
}

func printHeader() {
	purple.Printf("🚀 Envault v%s\n", Version)
	blue.Println("Interactive GitHub Secrets & Variables Management Tool")
	cyan.Println("Say NO to lazy work! 🔐✨")
	fmt.Println()
}

func validateInputs() error {
	// Check if env file exists
	if _, err := os.Stat(envFile); os.IsNotExist(err) {
		return fmt.Errorf("environment file not found: %s", envFile)
	}

	// Auto-detect repository if not provided
	if repository == "" {
		if detected, err := detectRepository(); err == nil {
			repository = detected
			blue.Printf("🔍 Auto-detected repository: %s\n", repository)
		} else {
			return fmt.Errorf("repository not specified and auto-detection failed")
		}
	}

	// Auto-detect environment if not provided
	if environment == "" {
		environment = detectEnvironment(envFile)
		blue.Printf("🔍 Auto-detected environment: %s\n", environment)
	}

	// Validate repository format
	if !regexp.MustCompile(`^[^/]+/[^/]+$`).MatchString(repository) {
		return fmt.Errorf("invalid repository format. Use: owner/repo")
	}

	return nil
}

func detectRepository() (string, error) {
	// Try to get repository from git remote
	cmd := exec.Command("git", "config", "--get", "remote.origin.url")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	url := strings.TrimSpace(string(output))

	// Extract owner/repo from various Git URL formats
	patterns := []string{
		`github\.com[:/]([^/]+/[^/]+?)(?:\.git)?$`,
		`github\.com/([^/]+/[^/]+?)(?:\.git)?$`,
	}

	for _, pattern := range patterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindStringSubmatch(url)
		if len(matches) > 1 {
			return matches[1], nil
		}
	}

	return "", fmt.Errorf("could not extract repository from git remote")
}

func detectEnvironment(filename string) string {
	base := filepath.Base(filename)
	switch {
	case strings.Contains(base, "production"):
		return "production"
	case strings.Contains(base, "staging"):
		return "staging"
	case strings.Contains(base, "development") || strings.Contains(base, "dev"):
		return "development"
	case strings.Contains(base, "test"):
		return "test"
	default:
		return "development"
	}
}

func setupGitHubClient() (*github.Client, error) {
	// Try to get GitHub token from gh CLI
	token, err := getGitHubToken()
	if err != nil {
		return nil, fmt.Errorf("GitHub authentication required. Run: gh auth login")
	}

	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(context.Background(), ts)
	client := github.NewClient(tc)

	// Test authentication
	_, _, err = client.Users.Get(context.Background(), "")
	if err != nil {
		return nil, fmt.Errorf("GitHub authentication failed: %v", err)
	}

	green.Println("✅ GitHub authentication successful")
	return client, nil
}

func getGitHubToken() (string, error) {
	// Try to get token from gh CLI
	cmd := exec.Command("gh", "auth", "token")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}

	token := strings.TrimSpace(string(output))
	if token == "" {
		return "", fmt.Errorf("no GitHub token found")
	}

	return token, nil
}

func parseEnvFile(filename string) ([]EnvVar, error) {
	envMap, err := godotenv.Read(filename)
	if err != nil {
		return nil, err
	}

	var variables []EnvVar
	for name, value := range envMap {
		if name != "" && value != "" {
			variables = append(variables, EnvVar{
				Name:   name,
				Value:  value,
				Source: filepath.Base(filename),
			})
		}
	}

	// Sort variables by name for consistent output
	sort.Slice(variables, func(i, j int) bool {
		return variables[i].Name < variables[j].Name
	})

	return variables, nil
}

func processVariables(client *github.Client, variables []EnvVar) (int, int) {
	uploaded := 0
	skipped := 0

	if autoMode {
		cyan.Println("🤖 AUTO MODE - Using smart classification")
	} else {
		green.Println("👤 INTERACTIVE MODE - You decide each variable")
	}

	fmt.Println()

	for i, variable := range variables {
		fmt.Printf("[%d/%d] ", i+1, len(variables))

		var classification Classification
		if autoMode {
			classification = classifyVariable(variable)
			fmt.Printf("%s: %s → %s\n",
				cyan.Sprint(variable.Name),
				variable.Value[:min(20, len(variable.Value))]+"...",
				getClassificationColor(classification).Sprint(classification))
		} else {
			classification = askClassification(variable)
		}

		if classification == Skip {
			skipped++
			continue
		}

		if dryRun {
			fmt.Printf("  🔍 DRY RUN: Would upload as %s\n", classification)
			uploaded++
			continue
		}

		if err := uploadVariable(client, variable, classification); err != nil {
			red.Printf("  ❌ Failed to upload %s: %v\n", variable.Name, err)
			skipped++
		} else {
			green.Printf("  ✅ Uploaded %s as %s\n", variable.Name, classification)
			uploaded++
		}

		fmt.Println()
	}

	return uploaded, skipped
}

func classifyVariable(variable EnvVar) Classification {
	name := strings.ToLower(variable.Name)
	value := strings.ToLower(variable.Value)

	// Secret patterns
	secretPatterns := []string{
		"password", "secret", "key", "token", "auth", "private",
		"credential", "cert", "ssl", "tls", "oauth", "jwt",
		"api_key", "database_password", "db_pass", "smtp_pass",
	}

	for _, pattern := range secretPatterns {
		if strings.Contains(name, pattern) {
			return Secret
		}
	}

	// Value-based detection
	if len(variable.Value) > 32 && (strings.Contains(value, "sk-") ||
		strings.Contains(value, "ghp_") || strings.Contains(value, "ghs_")) {
		return Secret
	}

	// Public variable patterns
	publicPatterns := []string{
		"url", "host", "port", "name", "env", "debug", "mode",
		"public", "next_public", "react_app", "vue_app",
	}

	for _, pattern := range publicPatterns {
		if strings.Contains(name, pattern) {
			return Variable
		}
	}

	// Default to Variable for ambiguous cases
	return Variable
}

func askClassification(variable EnvVar) Classification {
	fmt.Printf("%s: %s\n", cyan.Sprint(variable.Name), variable.Value[:min(50, len(variable.Value))])

	suggestion := classifyVariable(variable)
	fmt.Printf("  💡 Suggested: %s\n", getClassificationColor(suggestion).Sprint(suggestion))

	for {
		fmt.Print("  Choose: [S]ecret, [V]ariable, [K]eep suggestion, [X]skip: ")

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
			yellow.Println("  Invalid choice. Please enter S, V, K, or X")
		}
	}
}

func getClassificationColor(c Classification) *color.Color {
	switch c {
	case Secret:
		return red
	case Variable:
		return green
	default:
		return yellow
	}
}

func uploadVariable(client *github.Client, variable EnvVar, classification Classification) error {
	ctx := context.Background()
	parts := strings.Split(repository, "/")
	owner, repo := parts[0], parts[1]

	// Add environment prefix if not production
	varName := variable.Name
	if environment != "production" {
		varName = strings.ToUpper(environment) + "_" + variable.Name
	}

	if classification == Secret {
		return uploadSecret(ctx, client, owner, repo, varName, variable.Value)
	}
	return uploadEnvVariable(ctx, client, owner, repo, varName, variable.Value)
}

func uploadSecret(ctx context.Context, client *github.Client, owner, repo, name, value string) error {
	// Get repository public key for encryption
	publicKey, _, err := client.Actions.GetRepoPublicKey(ctx, owner, repo)
	if err != nil {
		return fmt.Errorf("failed to get repository public key: %v", err)
	}

	// Encrypt the secret value
	encryptedValue, err := encryptSecret(*publicKey.Key, value)
	if err != nil {
		return fmt.Errorf("failed to encrypt secret: %v", err)
	}

	// Create or update the secret
	secret := &github.EncryptedSecret{
		Name:           name,
		KeyID:          *publicKey.KeyID,
		EncryptedValue: encryptedValue,
	}

	if environment != "" && environment != "production" {
		// Upload to environment
		_, err = client.Actions.CreateOrUpdateEnvSecret(ctx, owner, repo, environment, secret)
	} else {
		// Upload to repository
		_, err = client.Actions.CreateOrUpdateRepoSecret(ctx, owner, repo, secret)
	}

	return err
}

func uploadEnvVariable(ctx context.Context, client *github.Client, owner, repo, name, value string) error {
	variable := &github.ActionsVariable{
		Name:  &name,
		Value: &value,
	}

	if environment != "" && environment != "production" {
		// Upload to environment
		_, err := client.Actions.CreateOrUpdateEnvVariable(ctx, owner, repo, environment, variable)
		return err
	} else {
		// Upload to repository
		_, err := client.Actions.CreateOrUpdateRepoVariable(ctx, owner, repo, variable)
		return err
	}
}

func printSummary(uploaded, skipped int) {
	fmt.Println()
	green.Printf("🎉 Upload completed for %s!\n", environment)
	green.Printf("📊 Uploaded: %d\n", uploaded)
	if skipped > 0 {
		yellow.Printf("📊 Skipped: %d\n", skipped)
	}

	if dryRun {
		blue.Println("💡 Run without --dry-run to actually upload")
	}

	fmt.Println()
	green.Println("✅ Done!")
	purple.Println("🧠 You were smart about your secrets - no lazy work here!")
	blue.Println("💙 Thank you for using Envault!")
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
