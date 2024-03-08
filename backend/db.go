package main

import (
	"database/sql"
	"log"
	"os"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

type DBInterface interface {
    SaveUserToDatabase(user User)
}

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

func (client *DBClient) SaveUserToDatabase(user User) error {
    query := "INSERT INTO users (user_id, display_name, email) VALUES (?, ?, ?)"
    
    _, err := client.DB.Exec(query, user.ID, user.DisplayName, user.Email)
    if err != nil {
        log.Printf("Error inserting new user into database: %v", err)
        return err
    }

    return nil
}
