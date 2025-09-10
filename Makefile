# Envault Makefile

# Binary name
BINARY_NAME=envault

# Build directory
BUILD_DIR=build

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Version and build info
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
GIT_COMMIT?=$(shell git rev-parse HEAD 2>/dev/null || echo "unknown")

# Build flags
LDFLAGS=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -X main.GitCommit=$(GIT_COMMIT)"

# Default target
.PHONY: all
all: clean build

# Build the binary
.PHONY: build
build:
	@echo "🔨 Building envault..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) .
	@echo "✅ Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

# Build for multiple platforms
.PHONY: build-all
build-all: clean
	@echo "🔨 Building for multiple platforms..."
	@mkdir -p $(BUILD_DIR)

	# Linux amd64
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 .

	# Linux arm64
	GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 .

	# macOS amd64
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 .

	# macOS arm64 (Apple Silicon)
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 .

	# Windows amd64
	GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe .

	@echo "✅ Multi-platform build complete!"
	@ls -la $(BUILD_DIR)/

# Install the binary to system PATH
.PHONY: install
install: build
	@echo "📦 Installing envault to /usr/local/bin..."
	@sudo cp $(BUILD_DIR)/$(BINARY_NAME) /usr/local/bin/$(BINARY_NAME)
	@sudo chmod +x /usr/local/bin/$(BINARY_NAME)
	@echo "✅ Envault installed! Run 'envault --help' to get started."

# Install locally (user bin)
.PHONY: install-local
install-local: build
	@echo "📦 Installing envault to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	@cp $(BUILD_DIR)/$(BINARY_NAME) ~/.local/bin/$(BINARY_NAME)
	@chmod +x ~/.local/bin/$(BINARY_NAME)
	@echo "✅ Envault installed locally!"
	@echo "💡 Make sure ~/.local/bin is in your PATH"

# Run tests
.PHONY: test
test:
	@echo "🧪 Running tests..."
	$(GOTEST) -v ./...

# Clean build artifacts
.PHONY: clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	$(GOCLEAN)
	@rm -rf $(BUILD_DIR)

# Download dependencies
.PHONY: deps
deps:
	@echo "📥 Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy

# Run the application in development
.PHONY: dev
dev: build
	@echo "🚀 Running envault in development mode..."
	@./$(BUILD_DIR)/$(BINARY_NAME) --help

# Create a release archive
.PHONY: release
release: build-all
	@echo "📦 Creating release archives..."
	@mkdir -p $(BUILD_DIR)/release

	# Create archives for each platform
	@cd $(BUILD_DIR) && tar -czf release/$(BINARY_NAME)-$(VERSION)-linux-amd64.tar.gz $(BINARY_NAME)-linux-amd64
	@cd $(BUILD_DIR) && tar -czf release/$(BINARY_NAME)-$(VERSION)-linux-arm64.tar.gz $(BINARY_NAME)-linux-arm64
	@cd $(BUILD_DIR) && tar -czf release/$(BINARY_NAME)-$(VERSION)-darwin-amd64.tar.gz $(BINARY_NAME)-darwin-amd64
	@cd $(BUILD_DIR) && tar -czf release/$(BINARY_NAME)-$(VERSION)-darwin-arm64.tar.gz $(BINARY_NAME)-darwin-arm64
	@cd $(BUILD_DIR) && zip release/$(BINARY_NAME)-$(VERSION)-windows-amd64.zip $(BINARY_NAME)-windows-amd64.exe

	@echo "✅ Release archives created in $(BUILD_DIR)/release/"
	@ls -la $(BUILD_DIR)/release/

# Show help
.PHONY: help
help:
	@echo "🚀 Envault Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build         Build the binary for current platform"
	@echo "  build-all     Build for all supported platforms"
	@echo "  install       Install to /usr/local/bin (requires sudo)"
	@echo "  install-local Install to ~/.local/bin"
	@echo "  test          Run tests"
	@echo "  clean         Clean build artifacts"
	@echo "  deps          Download and tidy dependencies"
	@echo "  dev           Build and show help"
	@echo "  release       Create release archives for all platforms"
	@echo "  help          Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make build-all"
	@echo "  make release"
