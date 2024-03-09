package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type Environment struct {
	ID            string   `json:"id"`
	Title         string   `json:"title"`
}

func getEnvironmentMetadata(c *gin.Context) {
	/*
	fetch all environment metadata from db
	*/
	dbInterface, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	db, ok := dbInterface.(*DBClient)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
		return
	}

	rows, err := db.DB.Query("SELECT * FROM environments")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	environments := []Environment{}
	var primaryKey int

	for rows.Next() {
		var environment Environment
		if err := rows.Scan(&primaryKey, &environment.ID, &environment.Title); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		environments = append(environments, environment)
	}

	c.IndentedJSON(http.StatusOK, environments)
}

func getEnvironmentFile(c *gin.Context) {
	/*
	fetch file with key "<id>.epub" from aws s3
	*/
	s3Interface, exists := c.Get("s3")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "S3 connection not available"})
		return
	}

	s3, ok := s3Interface.(S3Interface)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "S3 connection is of incorrect type"})
		return
	}

	id := c.Param("environment_id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing environment ID"})
		return
	}
	key := fmt.Sprintf("environments/%s.mov", id)

    // Generate a signed URL for the S3 object
    signedURL, err := s3.GetSignedURL(key)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

	log.Println(signedURL)

    // Return the signed URL to the client
    c.JSON(http.StatusOK, gin.H{"url": signedURL})
}

