package main 

import (
    "archive/zip"
    "database/sql"
    "encoding/json"
    "encoding/xml"
    "fmt"
    "io"
	"strings"
	"github.com/google/uuid"
    _ "github.com/go-sql-driver/mysql"
)

// Define structures to match the content.opf XML structure
type Package struct {
	Metadata Metadata `xml:"metadata"`
}

type Metadata struct {
	Titles         []string `xml:"title"`
	Creators       []string `xml:"creator"`
	Publishers     []string `xml:"publisher"`
	PublishedDates []string `xml:"date"`
	Tags           []string `xml:"subject"`
}

func ParseEPUB(filePath string, db *sql.DB) (Book, error) {
    r, err := zip.OpenReader(filePath)
    if err != nil {
        return Book{}, err
    }
    defer r.Close()

    var bookMetadata Package
    for _, f := range r.File {
        if strings.Contains(f.Name, "content.opf") {
            rc, err := f.Open()
            if err != nil {
                return Book{}, err
            }
            defer rc.Close()

            content, err := io.ReadAll(rc)
            if err != nil {
                return Book{}, err
            }

            err = xml.Unmarshal(content, &bookMetadata)
            if err != nil {
                return Book{}, err
            }

            break
        }
    }

    if len(bookMetadata.Metadata.Titles) == 0 {
        return Book{}, fmt.Errorf("no title found in EPUB metadata")
    }

    // Create a book instance with the parsed metadata
    book := Book{
		ID: 		   uuid.New().String(),
        Title:         bookMetadata.Metadata.Titles[0],
        Author:        strings.Join(bookMetadata.Metadata.Creators, ", "),
        Publisher:     strings.Join(bookMetadata.Metadata.Publishers, ", "),
        PublishedDate: strings.Join(bookMetadata.Metadata.PublishedDates, ", "),
        Tags:          bookMetadata.Metadata.Tags, // Store tags as a JSON string
    }

    // Convert Tags slice to JSON string for MySQL
    tagsJSON, err := json.Marshal(bookMetadata.Metadata.Tags)
    if err != nil {
        return Book{}, err
    }

    // Insert the book into the database
    stmt, err := db.Prepare("INSERT INTO books (id, title, author, publisher, publishedDate, tags) VALUES (?, ?, ?, ?, ?)")
    if err != nil {
        return Book{}, err
    }
    defer stmt.Close()

    _, err = stmt.Exec(book.ID, book.Title, book.Author, book.Publisher, book.PublishedDate, string(tagsJSON))
    if err != nil {
        return Book{}, err
    }

    return book, nil
}
