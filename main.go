package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {

	router := gin.Default()
	router.Any("/download/*proxyPath", handleDownload)

	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func handleDownload(c *gin.Context) {
	proxyPath := c.Param("proxyPath")

	remoteURL := "https://github.com/" + proxyPath
	log.Println("remoteURL:", remoteURL)

	// Perform an HTTP GET to retrieve the remote file
	resp, err := http.Get(remoteURL)
	if err != nil {
		c.String(http.StatusInternalServerError, "Error retrieving file: %v", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		c.String(resp.StatusCode, "Remote server returned status code: %d", resp.StatusCode)
		return
	}

	// Read the Content-Type from the upstream response
	contentType := resp.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}

	// You could derive a filename dynamically; here we hardcode "file.pdf"
	fileName := "file.pdf"

	// Set headers so the client knows how to handle/label the streamed file
	c.Header("Content-Disposition", fmt.Sprintf(`inline; filename="%s"`, fileName))
	c.Header("Content-Type", contentType)

	// Stream the remote file directly to the client.
	// DataFromReader does not buffer the entire file in memory.
	c.DataFromReader(
		http.StatusOK,
		resp.ContentLength, // The expected content length, if known
		contentType,
		resp.Body,
		nil,
	)
}
