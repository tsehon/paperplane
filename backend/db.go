package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
    "time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

type DBClient struct {
	DB *sql.DB
}

func NewDBClient() *DBClient {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	// Get environment variables
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")

	// Construct DSN (Data Source Name)
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPassword, dbHost, dbPort, dbName)

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal(err)
	}

	return &DBClient{
		DB: db,
	}
}

func (db *DBClient) GetUser(userID string) (User, error) {
	var user User
	query := "SELECT * FROM users WHERE user_id = ?"

	rows, err := db.DB.Query(query, userID)
	if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, userID, err)
		return user, err
	}
	defer rows.Close()

	var emailVerified sql.NullBool
	var bio sql.NullString
	var preferencesJson string

	if err := rows.Scan(&user.ID, &user.DisplayName, &user.Email, emailVerified, bio, preferencesJson); err != nil {
		return user, err
	}

	if err := json.Unmarshal([]byte(preferencesJson), &user.Preferences); err != nil {
        return user, err
	}

	if emailVerified.Valid {
		user.EmailVerified = emailVerified.Bool
	} 
	if bio.Valid {
		user.Bio = bio.String
	}

    return user, nil
}

func (db *DBClient) SaveUser(user User) error {
	query := "INSERT INTO users (user_id, display_name, email) VALUES (?, ?, ?)"

	_, err := db.DB.Exec(query, user.ID, user.DisplayName, user.Email)
	if err != nil {
		log.Printf("Error inserting new user into database: %v", err)
		return err
	}

	return nil
}

func (db *DBClient) UpdateUser(userID string, updateFields map[string]interface{}) error {
	// Construct SQL query dynamically based on the fields present in the request
	var setClauses []string
	var args []interface{}

    // parse lastLogin field as RFC3339
    if lastLoginStr, ok := updateFields["lastLogin"].(string); ok {
        lastLoginTime, err := time.Parse(time.RFC3339, lastLoginStr)
        if err != nil {
            return err
        }
        updateFields["lastLogin"] = lastLoginTime
    }

	for field, value := range updateFields {
		dbField := strings.Replace(field, "displayName", "display_name", 1)
		dbField = strings.Replace(dbField, "emailVerified", "email_verified", 1)
		dbField = strings.Replace(dbField, "lastLogin", "last_login", 1)

		setClauses = append(setClauses, fmt.Sprintf("%s = ?", dbField))
		args = append(args, value)
	}
	query := fmt.Sprintf("UPDATE users SET %s WHERE user_id = ?", strings.Join(setClauses, ", "))
	args = append(args, userID)

	_, err := db.DB.Exec(query, args...)
    if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, args, err)
        return err
    }

	return nil 
}

func (db *DBClient) GetUserBooks(userID string) ([]UserBook, error) {
    query := "SELECT * from users_books WHERE user_id = ?"
    args := []interface{}{userID}

    rows, err := db.DB.Query(query, args...)
    if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, args, err)
        return nil, err
    }
    defer rows.Close()

    userBooks := []UserBook{}
    var locatorJson string 

    for rows.Next() {
        var userBook UserBook
		if err := rows.Scan(&userBook.UserID, &userBook.BookID, &userBook.ReadingStatus, &userBook.Liked, &userBook.Progress, locatorJson, &userBook.LastRead); err != nil {
			return userBooks, err
		}

		if err := json.Unmarshal([]byte(locatorJson), &userBook.Locator); err != nil {
			log.Fatal("Unmarshal locator failed:", err)
            return userBooks, err
		}

        userBooks = append(userBooks, userBook)
    }

    return userBooks, nil
}

func (db *DBClient) GetUserBook(userID string, bookID string) (UserBook, error) {
    query := "SELECT * from users_books WHERE user_id = ? AND book_id = ?"
    args := []interface{}{userID, bookID}
    var userBook UserBook

    rows, err := db.DB.Query(query, args...)

    if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, args, err)
        return userBook, err
    }
    defer rows.Close()

    var locatorJson string 
    if err := rows.Scan(&userBook.UserID, &userBook.BookID, &userBook.ReadingStatus, &userBook.Liked, &userBook.Progress, locatorJson, &userBook.LastRead); err != nil {
        return userBook, err
    }

    if err := json.Unmarshal([]byte(locatorJson), &userBook.Locator); err != nil {
        log.Fatal("Unmarshal locator failed:", err)
        return userBook, err
    }

    return userBook, nil
}

func (db *DBClient) AddUserBook(userBook UserBook) error {
    locatorJSON, err := json.Marshal(userBook.Locator)
	if err != nil {
		return err
	}

    query := "INSERT INTO users_books (user_id, book_id, reading_status, liked, progress, locator) VALUES (?, ?, ?, ?, ?, ?)"
    args := []interface{}{userBook.UserID, userBook.BookID, userBook.ReadingStatus, userBook.Liked, userBook.Progress, locatorJSON}

    _, err = db.DB.Exec(query, args...)
	if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, args, err)
		return err
	}

    return nil
}

func (db *DBClient) UpdateUserBook(userID string, bookID string, updateFields map[string]interface{}) error {
	// Construct SQL query dynamically based on the fields present in the request
	var setClauses []string
	var args []interface{}

	for field, value := range updateFields {
		dbField := strings.Replace(field, "readingStatus", "reading_status", 1)
		dbField = strings.Replace(dbField, "lastRead", "last_read", 1)

		setClauses = append(setClauses, fmt.Sprintf("%s = ?", dbField))
		args = append(args, value)
	}

	query := fmt.Sprintf("UPDATE users_books SET %s WHERE user_id = ? AND books_id = ?", strings.Join(setClauses, ", "))
	args = append(args, userID, bookID)

	_, err := db.DB.Exec(query, args...)
    if err != nil {
        log.Printf("Failed to execute query: %s\nArguments: %v\nError: %s\n", query, args, err)
        return err
    }

	return nil
}
