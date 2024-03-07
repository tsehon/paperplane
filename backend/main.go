package main 

import (
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

	/* bookmarks */
	router.GET("/bookmarks/:user_id")
	router.GET("/bookmarks/:user_id/:book_id")
	router.POST("/bookmarks")

	/* books */
	router.GET("/books/metadata", getBooksMetadata)
	router.GET("/books/metadata/:book_id", getBookMetadata)
	router.GET("/books/:book_id", getBookFile)
	router.GET("/books/:book_id/cover", getBookCover)
	router.POST("/books", uploadBook)
	
	/* environments */
	router.GET("/environments/metadata", getEnvironmentMetadata)
	router.GET("/environments/:environment_id", getEnvironmentFile)

	/* highlights */
	router.GET("/highlights/:user_id")
	router.GET("/highlights/:user_id/:book_id")
	router.POST("/highlights", uploadBook)

	/* notes */
	router.GET("/notes/:user_id")
	router.GET("/notes/:user_id/:book_id")
	router.POST("/notes", uploadBook)

	/* reviews */
	router.GET("/reviews/:book_id")
	router.GET("/reviews/:book_id/:user_id")
	router.GET("/reviews/user/:user_id")
	router.POST("/reviews")

	/* tags */
	router.GET("/tags", getAllTags)

	/* users */
	router.GET("/users/:user_id/books")
	router.GET("/users/:user_id/book_id")
	router.GET("/users/:user_id/preferences")
	router.GET("/users/:user_id/liked")

	router.Run(":8080")
}

