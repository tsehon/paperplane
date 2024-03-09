package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type User struct {
	ID            string   `json:"userId"`
	DisplayName   string   `json:"displayName"`
	Email 		  string   `json:"email"`
	EmailVerified bool `json:"emailVerified"`
    Bio string`json:"bio"`
    Preferences map[string]interface{} `json:"preferences"`
}

type UserBook struct {
	UserID string   `json:"userId"`
	BookID            string   `json:"bookId"`
	ReadingStatus string `json:"readingStatus"`
	Liked bool `json:"liked"`
	Progress float64 `json:"progress"`
	Locator map[string]interface{} `json:"locator"`
	LastRead time.Time `json:"lastRead"`
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing userID"})
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
		c.Error(err)
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

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

    var newUser User

    if err := c.BindJSON(&newUser); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user data", "msg": err.Error()})
        return
    }

    if err := db.SaveUser(newUser); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save user to database", "msg": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "New user data synced to db"})
}

func updateUser(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

    userID := c.Param("user_id")
    if userID == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user ID"})
        return
    }

	var updateFields map[string]interface{}
	if err := c.BindJSON(&updateFields); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "msg": err.Error()})
		return
	}

	if err := db.UpdateUser(userID, updateFields); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user", "msg": err.Error()})
		return
	}

    c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
}

func getUserBooks(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

	userID := c.Param("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user_id"})
		return
	}

	userBooks, err := db.GetUserBooks(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	c.IndentedJSON(http.StatusOK, userBooks)
}

func getUserBook(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

	userID := c.Param("user_id")
	bookID := c.Param("book_id")
	if userID == "" || bookID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Empty ID value"})
	}

	userBook, err := db.GetUserBook(userID, bookID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	c.JSON(http.StatusOK, userBook)
}

func addUserBook(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

    userID := c.Param("user_id")
    if userID == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user ID"})
        return
    }

	var userBook UserBook
	userBook.UserID = userID

	if err := c.BindJSON(&userBook); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "msg": err.Error()})
		return
	}

	if err := db.AddUserBook(userBook); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
	}

	c.JSON(http.StatusOK, gin.H{"message": "New User Book added"})
}

func updateUserBook(c *gin.Context) {
    dbClientInterface, exists := c.Get("db")
    if !exists {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
        return
    }

    db, ok := dbClientInterface.(*DBClient)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

    userID := c.Param("user_id")
    if userID == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Missing user ID"})
        return
    }

    bookID := c.Param("book_id")
    if userID == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Missing book ID"})
        return
    }

	var updateFields map[string]interface{}
	if err := c.BindJSON(&updateFields); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body", "msg": err.Error()})
		return
	}

	if err := db.UpdateUserBook(userID, bookID, updateFields); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "DB Update Failed", "msg": err.Error()})
        return
	}
}