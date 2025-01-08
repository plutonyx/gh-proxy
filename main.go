package main

import (
	"fmt"
	"log"
	"net/http"
	"regexp"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {

	r := gin.Default()
	r.Any("/show/*targetUrl", showMeTheContent)
	r.Any("/download/*proxyPath", handleDownload)

	srv := &http.Server{
		Addr:    ":8080",
		Handler: r,
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

	// Extract the filename from the URL
	fileName := urlPathToFilename(remoteURL)

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

func urlPathToFilename(url string) string {
	// Extract the last part of the URL path as the filename
	// e.g. "https://example.com/path/to/file.txt" -> "file.txt"
	// This is a naive implementation and may not work for all URLs.
	// For production use, you may want to use a more robust method.
	// For example, you could use the "Content-Disposition" header from the upstream response.
	// Or you could use a library like "github.com/golang/url" to parse the URL.
	// Or you could use a more robust regular expression.
	// This is just a simple example.
	for i := len(url) - 1; i >= 0; i-- {
		if url[i] == '/' {
			return url[i+1:]
		}
	}
	return fmt.Sprintf("file-%d", time.Now().Unix())
}

func showMeTheContent(c *gin.Context) {
	targetUrl := c.Param("targetUrl")
	if targetUrl == "" {
		c.String(http.StatusBadRequest, "No targetUrl provided")
		return
	}
	// trim the leading slash
	targetUrl = targetUrl[1:]

	validUrlRegex := "^(http|https)://"
	if !regexp.MustCompile(validUrlRegex).MatchString(targetUrl) {
		c.String(http.StatusBadRequest, "Invalid URL")
		return
	}

	// Perform an HTTP GET to retrieve the remote file
	resp, err := http.Get(targetUrl)
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

	// return the content
	c.DataFromReader(
		http.StatusOK,
		resp.ContentLength, // The expected content length, if known
		contentType,
		resp.Body,
		nil,
	)
}
