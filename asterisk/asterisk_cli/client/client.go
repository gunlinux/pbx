package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
  //"strings"
  "io"
)

type Command struct {
	Bin      string `json:"bin"`
	Commands []string `json:"commands"`
}

type Response struct {
	Output string `json:"output"`
}

func getEnv(key string) string {
	value, exists := os.LookupEnv(key)
	if !exists {
		log.Fatalf("Environment variable %s not set", key)
	}
	return value
}

func printOutputFromJSON(jsonResponse []byte) {
	// Unmarshal the JSON response into the Response struct
	var response Response
	err := json.Unmarshal([]byte(jsonResponse), &response)
	if err != nil {
		log.Fatalf("Error unmarshaling JSON response: %v", err)
	}

	// Print the output field
	fmt.Println(response.Output)
}

func main() {
	// Get the HOST and PORT from environment variables
	host := getEnv("ASTERISK_CLI_HOST")
	port := getEnv("ASTERISK_CLI_PORT")
	url := fmt.Sprintf("http://%s:%s", host, port)

	// Get the command and its arguments from command-line arguments
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run main.go <bin> <commands>")
		os.Exit(1)
	}

	bin := "asterisk"
	commands := os.Args[1:]

	// Create the JSON payload
	payload := Command{
		Bin:      bin,
		Commands: commands,
	}
	jsonData, err := json.Marshal(payload)
	if err != nil {
		log.Fatalf("Error marshaling JSON: %v", err)
	}

	// Send the POST request
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		log.Fatalf("Error sending POST request: %v", err)
	}
	defer resp.Body.Close()

	// Read and print the response
	responseBody, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("Error reading response: %v", err)
	}
  printOutputFromJSON(responseBody)
}

