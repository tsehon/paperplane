package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type User struct {
	ID            string   `json:"userId"`
	DisplayName   string   `json:"displayName"`
	Email 		  string   `json:"email"`
	EmailVerified bool `json:"emailVerified"`
    Bio string`json:"bio"`
    Preferences []byte `json:"preferences"`
}

func getUser(c *gin.Context) {
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

	id := c.Param("user_id")
	if id == "" {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrive user ID"})
		return
	}

	query := "SELECT * FROM users WHERE user_id = ?"
	rows, err := db.DB.Query(query, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var user User
	var emailVerified sql.NullBool
	var bio sql.NullString
	var preferencesJson string

	if err := rows.Scan(&user.ID, &user.DisplayName, &user.Email, emailVerified, bio, preferencesJson); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := json.Unmarshal([]byte(preferencesJson), &user.Preferences); err != nil {
		log.Fatal("Unmarshal tags failed:", err)
	}

	if emailVerified.Valid {
		user.EmailVerified = emailVerified.Bool
	} 
	if bio.Valid {
		user.Bio = bio.String
	}

	c.IndentedJSON(http.StatusOK, user)
}

func addUser(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    dbClient, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

    var newUser User

    if err := c.BindJSON(&newUser); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user data"})
        return
    }

    if err := dbClient.SaveUserToDatabase(newUser); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save user to database"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "New user data synced to db"})
}