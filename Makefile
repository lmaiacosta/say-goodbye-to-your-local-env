# Envault Makefile

BINARY_NAME=envault
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "2.0.0")
BUILD_DIR=build
LDFLAGS=-ldflags "-X main.Version=$(VERSION)"

.PHONY: all build build-all clean install test

all: build

build:
	@echo "🔨 Building $(BINARY_NAME)..."
	go build $(LDFLAGS) -o $(BINARY_NAME) .

build-all: clean
	@echo "🔨 Building for all platforms..."
	@mkdir -p $(BUILD_DIR)
	@echo "Building for Linux amd64..."
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 .
	@echo "Building for Linux arm64..."
	GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 .
	@echo "Building for Windows amd64..."
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe .
	@echo "Building for Windows arm64..."
	GOOS=windows GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe .
	@echo "Building for macOS amd64..."
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 .
	@echo "Building for macOS arm64..."
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 .

install: build
	@echo "📦 Installing $(BINARY_NAME)..."
	sudo mv $(BINARY_NAME) /usr/local/bin/

clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(BINARY_NAME)
	@rm -rf $(BUILD_DIR)

test:
	@echo "🧪 Running tests..."
	go test -v ./...

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build      - Build the binary for current platform"
	@echo "  build-all  - Build for all platforms (Linux, Windows, macOS)"
	@echo "  install    - Install to /usr/local/bin"
	@echo "  clean      - Clean build artifacts"
	@echo "  test       - Run tests"
	@echo "  help       - Show this help"
