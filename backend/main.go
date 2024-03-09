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
        c.Set("db", db) 
		c.Set("s3", s3)
        c.Next()
    })

	/* bookmarks */
	router.POST("/bookmarks")
	router.GET("/bookmarks/:user_id")
	router.GET("/bookmarks/:user_id/:book_id")

	/* books */
	router.POST("/books", uploadBook)
	router.GET("/books/metadata", getBooksMetadata)
	router.GET("/books/metadata/:book_id", getBookMetadata)
	router.GET("/books/:book_id", getBookFile)
	router.GET("/books/:book_id/cover", getBookCover)
	
	/* environments */
	router.GET("/environments/metadata", getEnvironmentMetadata)
	router.GET("/environments/:environment_id", getEnvironmentFile)

	/* highlights */
	router.POST("/highlights")
	router.GET("/highlights/:user_id")
	router.GET("/highlights/:user_id/:book_id")

	/* notes */
	router.POST("/notes")
	router.GET("/notes/:user_id")
	router.GET("/notes/:user_id/:book_id")

	/* reviews */
	router.POST("/reviews")
	router.GET("/reviews/:book_id")
	router.GET("/reviews/:book_id/:user_id")
	router.GET("/reviews/user/:user_id")

	/* tags */
	router.GET("/tags", getAllTags)

	/* users */
	router.GET("/users/:user_id", getUser)
	router.PUT("/users/:user_id", addUser)
	router.PATCH("/users/:user_id", updateUser)
	router.GET("/users/:user_id/books", getUserBooks)
	router.PUT("/users/:user_id/books/:book_id", addUserBook)
	router.GET("/users/:user_id/books/:book_id", getUserBook)
	router.PATCH("/users/:user_id/books/:book_id", updateUserBook)
	//router.GET("/users/:user_id/preferences")
	//router.GET("/users/:user_id/liked")

	router.Run(":8080")
}

