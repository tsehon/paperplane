package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type Tag struct {
	ID    string `json:"tag_id"`
	Name string `json:"tag_name"`
}

func getAllTags(c *gin.Context) {
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

	rows, err := db.DB.Query("SELECT * FROM tags")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var tags []Tag
	for rows.Next() {
		var tag Tag 
		if err := rows.Scan(&tag.ID, &tag.Name); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		tags = append(tags, tag)
	}

	c.IndentedJSON(http.StatusOK, tags)
}
