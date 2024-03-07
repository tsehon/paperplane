package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
)

type Book struct {
	ID            string   `json:"id"`
	Title         string   `json:"title"`
	Author        string   `json:"author"`
	Tags          []string `json:"tags"`
	Rating        float32  `json:"rating"`
	Publisher     string   `json:"publisher"`
	PublishedDate string   `json:"publishedDate"`
}

func getBookMetadata(c *gin.Context) {
	/*
	fetch metadata from db for only one book, using id
	*/
	dbInterface, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	db, ok := dbInterface.(*sql.DB)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
		return
	}

	id := c.Param("book_id")
	row := db.QueryRow(`
		SELECT b.book_id, b.title, b.author, b.rating, b.publisher, b.publishedDate, 
		JSON_ARRAYAGG(t.tag_name) AS tags
		FROM books b
		LEFT JOIN books_tags bt ON b.book_id = bt.book_id
		LEFT JOIN tags t ON bt.tag_id = t.tag_id
		WHERE b.book_id = ?
		GROUP BY b.book_id;`, id)

	book := Book{}
	var rating sql.NullFloat64 // Use sql.NullFloat64 to handle nullable rating values
	var publisher sql.NullString
	var publishedDate sql.NullString
	var tagsJSON string 

	if err := row.Scan(&book.ID, &book.Title, &book.Author, &tagsJSON, &rating, &publisher, &publishedDate); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err := json.Unmarshal([]byte(tagsJSON), &book.Tags); err != nil {
		fmt.Print("unmarshalling tags failed")
		log.Fatal("Unmarshal tags failed:", err)
	}

	// convert non-null values to their respective types
	if rating.Valid {
		book.Rating = float32(rating.Float64)
	} else {
		book.Rating = 0
	}
	if publisher.Valid {
		book.Publisher = publisher.String
	} else {
		book.Publisher = ""
	}
	if publishedDate.Valid {
		book.PublishedDate = publishedDate.String
	} else {
		book.PublishedDate = ""
	}

	c.IndentedJSON(http.StatusOK, book)
}

func getBooksMetadata(c *gin.Context) {
	/*
	fetch all book metadata from db
	*/
	dbInterface, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	db, ok := dbInterface.(*sql.DB)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

	rows, err := db.Query(
		"SELECT b.book_id AS `ID`," +
			"b.title AS `Title`," +
			"b.author AS `Author`," + 
			"JSON_ARRAYAGG(t.tag_name) AS `Tags`," + 
			"b.rating AS `Rating`," + 
			"b.publisher AS `Publisher`," +
			"b.publishedDate AS `PublishedDate`" +
		
		`FROM books b
		LEFT JOIN books_tags bt ON b.book_id = bt.book_id
		LEFT JOIN tags t ON bt.tag_id = t.tag_id
		GROUP BY b.book_id
		ORDER BY b.book_id;`)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	books := []Book{}
	var rating sql.NullFloat64 // Use sql.NullFloat64 to handle nullable rating values
	var publisher sql.NullString
	var publishedDate sql.NullString
	var tagsJSON string 

	for rows.Next() {
		var book Book
		if err := rows.Scan(&book.ID, &book.Title, &book.Author, &tagsJSON, &rating, &publisher, &publishedDate); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		if err := json.Unmarshal([]byte(tagsJSON), &book.Tags); err != nil {
			log.Fatal("Unmarshal tags failed:", err)
		}

		// convert non-null values to their respective types
		if rating.Valid {
			book.Rating = float32(rating.Float64)
		} else {
			book.Rating = 0
		}
		if publisher.Valid {
			book.Publisher = publisher.String
		} else {
			book.Publisher = ""
		}
		if publishedDate.Valid {
			book.PublishedDate = publishedDate.String
		} else {
			book.PublishedDate = ""
		}

		books = append(books, book)
	}

	c.IndentedJSON(http.StatusOK, books)
}

func getBookFile(c *gin.Context) {
	/*
	fetch file with key "<book_id>.epub" from aws s3
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

	id := c.Param("book_id")
	key := fmt.Sprintf("books/%s.epub", id)

	// get object from s3
	resp, err := s3.GetFile(key)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

    defer resp.Body.Close()
    c.DataFromReader(http.StatusOK, *resp.ContentLength, "application/epub+zip", resp.Body, nil)
}

func getBookCover(c *gin.Context) {
	/*
	fetch cover with key "<book_id>.jpg" from aws s3
	*/
	s3Interface, exists := c.Get("s3")
	if !exists {
		log.Println("S3 connection not available")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "S3 connection not available"})
		return
	}

	s3, ok := s3Interface.(S3Interface)
	if !ok {
		log.Println("S3 connection is of incorrect type")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "S3 connection is of incorrect type"})
		return
	}

	id := c.Param("book_id")
	key := fmt.Sprintf("book_covers/%s.jpg", id)

	// get object from s3
	resp, err := s3.GetFile(key)
	if err != nil {
		log.Println("Error retrieving file from S3: ", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	defer resp.Body.Close()
	c.DataFromReader(http.StatusOK, *resp.ContentLength, "image/jpeg", resp.Body, nil)
}

func uploadBook(c *gin.Context) {
	/*
	parse epub, add to db, upload to s3
	*/
	dbInterface, exists := c.Get("db")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	db, ok := dbInterface.(*sql.DB)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

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

    // Parse the multipart form, 10 << 20 specifies a maximum upload of 10 MB files.
    if err := c.Request.ParseMultipartForm(10 << 20); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "File too large"})
        return
    }

    file, _, err := c.Request.FormFile("epubFile")
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file"})
        return
    }
    defer file.Close()

    // Create a temporary file to store the uploaded EPUB
    tempFile, err := os.CreateTemp("", "upload-*.epub")
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not create temp file"})
        return
    }
    defer tempFile.Close()

    // Copy the uploaded EPUB content to the temporary file
    _, err = io.Copy(tempFile, file)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save the file"})
        return
    }

    // Now you have the file path of the uploaded EPUB in tempFile.Name()
    // You can call your original logic here, assuming it's adapted to not return values but to interact with `c` directly.
    book, err := ParseEPUB(tempFile.Name(), db) // Adapt ParseEPUB accordingly.
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse EPUB"})
        return
    }

	// add to s3
	fileBytes, err := os.ReadFile(tempFile.Name())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read file"})
		return
	}

	err = s3.UploadFile(fmt.Sprintf("books/%s.epub", book.ID), fileBytes)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload file to S3"})
		return
	}

    // If everything is successful, respond with appropriate message
    c.JSON(http.StatusOK, gin.H{"message": "Book added successfully"})
}

