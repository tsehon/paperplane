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

func main() {
	router := gin.Default()

	db := NewDBClient() // database 
	s3 := NewS3Client() // storage
	defer db.DB.Close() 

	router.Use(func(c *gin.Context) { // add as middleware to router
        c.Set("db", db.DB) 
		c.Set("s3", s3)
        c.Next()
    })

	/* books */
	router.GET("/book/metadata", getBooksMetadata)
	router.GET("/book/metadata/:id", getBookMetadata)
	router.GET("/book/:id", getBookFile)
	router.GET("/book/tags", getAllTags)
	router.GET("/book/:id/cover", getBookCover)
	router.POST("/book", uploadBook)

	/* environments (a.k.a immersive spaces) */
	router.GET("/environment/metadata", getEnvironmentMetadata)
	router.GET("/environment/:id", getEnvironmentFile)

	router.Run(":8080")
}

/* BOOKS */
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

	id := c.Param("id")
	row := db.QueryRow("SELECT * FROM books WHERE id = ?", id)

	var primaryKey int
	var tagsJSON []byte // Assuming tags handling is already adjusted as previously discussed
	var rating sql.NullFloat64 // Use sql.NullFloat64 to handle nullable rating values
	var publisher sql.NullString
	var publishedDate sql.NullString
	book := Book{}

	if err := row.Scan(&primaryKey, &book.ID, &book.Title, &book.Author, &tagsJSON, &rating, &publisher, &publishedDate); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Unmarshal tags JSON
	if err := json.Unmarshal(tagsJSON, &book.Tags); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unmarshal tags JSON"})
		return
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

	rows, err := db.Query("SELECT * FROM books")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	books := []Book{}
	var primaryKey int
	var tagsJSON []byte // Assuming tags handling is already adjusted as previously discussed
	var rating sql.NullFloat64 // Use sql.NullFloat64 to handle nullable rating values
	var publisher sql.NullString
	var publishedDate sql.NullString

	for rows.Next() {
		var book Book
		if err := rows.Scan(&primaryKey, &book.ID, &book.Title, &book.Author, &tagsJSON, &rating, &publisher, &publishedDate); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		// Unmarshal tags JSON
		if err := json.Unmarshal(tagsJSON, &book.Tags); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unmarshal tags JSON"})
			return
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

	id := c.Param("id")
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
	fetch cover with key "<id>.jpg" from aws s3
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

	id := c.Param("id")
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

func getAllTags(c *gin.Context) {
	/*
	fetch all book tags from db
	TODO: Need to adjust this to get unique tags
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

	rows, err := db.Query("SELECT DISTINCT JSON_UNQUOTE(JSON_EXTRACT(tags, \"$[*]\")) AS tag FROM books")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	tags := []string{}

	for rows.Next() {
		var tag string
		if err := rows.Scan(&tag); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		tags = append(tags, tag)
	}

	c.IndentedJSON(http.StatusOK, tags)
}

/* ENVIRONMENTS */
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

	db, ok := dbInterface.(*sql.DB)
    if !ok {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection is of incorrect type"})
        return
    }

	rows, err := db.Query("SELECT * FROM environments")
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

	id := c.Param("id")
	key := fmt.Sprintf("environments/%s.mov", id)

    // Generate a signed URL for the S3 object
    signedURL, err := s3.GetSignedURL(key)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    // Return the signed URL to the client
    c.JSON(http.StatusOK, gin.H{"url": signedURL})

	/*
	// get object from s3 for download
	resp, err := s3.GetFile(key)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

    defer resp.Body.Close()
    c.DataFromReader(http.StatusOK, *resp.ContentLength, "video/quicktime", resp.Body, nil)
	*/
}