package main

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"

	"golang.org/x/crypto/nacl/box"
)

// encryptSecret encrypts a secret value using libsodium-style encryption
// compatible with GitHub's API requirements
func encryptSecret(publicKeyB64, secretValue string) (string, error) {
	// Decode the base64 public key
	publicKeyBytes, err := base64.StdEncoding.DecodeString(publicKeyB64)
	if err != nil {
		return "", fmt.Errorf("failed to decode public key: %v", err)
	}

	if len(publicKeyBytes) != 32 {
		return "", fmt.Errorf("invalid public key length: expected 32 bytes, got %d", len(publicKeyBytes))
	}

	// Convert to nacl/box public key format
	var publicKey [32]byte
	copy(publicKey[:], publicKeyBytes)

	// Generate a random nonce
	var nonce [24]byte
	if _, err := rand.Read(nonce[:]); err != nil {
		return "", fmt.Errorf("failed to generate nonce: %v", err)
	}

	// Encrypt the secret
	encrypted, err := box.SealAnonymous(nil, []byte(secretValue), &publicKey, rand.Reader)
	if err != nil {
		return "", fmt.Errorf("failed to encrypt secret: %v", err)
	}

	// Return base64 encoded result
	return base64.StdEncoding.EncodeToString(encrypted), nil
}
