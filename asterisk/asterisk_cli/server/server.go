package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
  //"strings"
)

type RequestBody struct {
	Bin string `json:"bin"`
	Commands []string `json:"commands"`
}

type ResponseBody struct {
	Output string `json:"output"`
}

func executeCommand(bin string, commands []string) (string, error) {
  fmt.Printf("Command is : %s\n", bin)


  cmd := exec.Command(bin, commands...)
  output, err := cmd.Output()
	return string(output), err
}

func handler(w http.ResponseWriter, r *http.Request) {

	fmt.Println("new req")
	// Only allow POST requests
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
	  fmt.Println("only post allowed")
		return
	}

	// Read the request body
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Unable to read request body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// Parse the JSON request
	var requestBody RequestBody
	err = json.Unmarshal(body, &requestBody)
	if err != nil {
		http.Error(w, "Invalid JSON format", http.StatusBadRequest)
		return
	}

	// Execute the command
	fmt.Println("time to execute command %s ", requestBody)
	fmt.Println("time to execute command %s ", requestBody.Bin)
	fmt.Println("time to execute command %s ", requestBody.Commands)

	output, err := executeCommand(requestBody.Bin, requestBody.Commands)
	if err != nil {
		http.Error(w, fmt.Sprintf("Command execution failed: %s", err), http.StatusInternalServerError)
		output = "error"
	}

	// Create the response
	responseBody := ResponseBody{
		Output: output,
	}
	responseJson, err := json.Marshal(responseBody)
	if err != nil {
		http.Error(w, "Failed to create response JSON", http.StatusInternalServerError)
		return
	}

	// Send the response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(responseJson)
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server is listening on port 5939")
	err := http.ListenAndServe(":5939", nil)
	if err != nil {
		fmt.Printf("Failed to start server: %s\n", err)
	}
}

