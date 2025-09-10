# Envault Makefile

BINARY_NAME=envault
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "2.0.0")
BUILD_DIR=build
LDFLAGS=-ldflags "-X main.Version=$(VERSION)"

.PHONY: all build build-all clean install test deps

all: build

# Install dependencies
deps:
	@echo "📦 Installing dependencies..."
	go mod tidy
	go mod download

# Build for current platform
build: deps
	@echo "🔨 Building $(BINARY_NAME) v$(VERSION)..."
	go build $(LDFLAGS) -o $(BINARY_NAME) .

# Build for all platforms
build-all: clean deps
	@echo "🔨 Building $(BINARY_NAME) v$(VERSION) for all platforms..."
	@mkdir -p $(BUILD_DIR)

	@echo "📦 Building for Linux amd64..."
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 .

	@echo "📦 Building for Linux arm64..."
	GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 .

	@echo "📦 Building for macOS amd64..."
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 .

	@echo "📦 Building for macOS arm64..."
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 .

	@echo "📦 Building for Windows amd64..."
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe .

	@echo "📦 Building for Windows arm64..."
	GOOS=windows GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe .

	@echo "✅ Built binaries:"
	@ls -la $(BUILD_DIR)/

# Install to system
install: build
	@echo "📋 Installing $(BINARY_NAME) to /usr/local/bin..."
	sudo mv $(BINARY_NAME) /usr/local/bin/
	@echo "✅ Installed! Run 'envault --version' to test"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(BINARY_NAME)
	@rm -rf $(BUILD_DIR)

# Run tests
test: deps
	@echo "🧪 Running tests..."
	go test -v ./...
	@echo "✅ Tests passed!"

# Development tasks
dev: build
	@echo "🚀 Development build ready!"
	@./$(BINARY_NAME) --version

# Show help
help:
	@echo "Available targets:"
	@echo "  deps       - Install dependencies"
	@echo "  build      - Build for current platform"
	@echo "  build-all  - Build for all platforms"
	@echo "  install    - Install to /usr/local/bin"
	@echo "  clean      - Clean build artifacts"
	@echo "  test       - Run tests"
	@echo "  dev        - Development build"
	@echo "  help       - Show this help"
