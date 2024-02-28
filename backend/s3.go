package main

import (
    "time"
	"github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/s3/s3manager"
    "github.com/aws/aws-sdk-go/service/s3"
	"bytes"
    "os"
	"github.com/joho/godotenv"
    "log"
)

type S3Interface interface {
	UploadFile(key string, body []byte) error
    GetFile(key string) (*s3.GetObjectOutput, error)
    GetSignedURL(key string) (string, error) // Add this method
}

type S3Client struct {
    Service  *s3.S3
    Uploader *s3manager.Uploader
}

func NewS3Client() *S3Client {
    if err := godotenv.Load(); err != nil {
        log.Fatal("Error loading .env file")
    }

    sess := session.Must(session.NewSession(&aws.Config{
        Region: aws.String(os.Getenv("AWS_REGION")),
    }))

    return &S3Client{
        Service: s3.New(sess),
        Uploader: s3manager.NewUploader(sess),
    }
}

func (s *S3Client) UploadFile(key string, body []byte) error {
    _, err := s.Uploader.Upload(&s3manager.UploadInput{
        Bucket: aws.String(os.Getenv("AWS_BUCKET")),
        Key:    aws.String(key),
        Body:   bytes.NewReader(body),
    })
    return err
}

func (s *S3Client) GetFile(key string) (*s3.GetObjectOutput, error) {
    if err := godotenv.Load(); err != nil {
        log.Fatal("Error loading .env file")
    }

    req, _ := s.Service.GetObjectRequest(&s3.GetObjectInput{
        Bucket: aws.String(os.Getenv("AWS_BUCKET")),
        Key:    aws.String(key),
    })

    _, err := req.Presign(15 * time.Minute) // Presign the URL to be valid for 15 minutes
    if err != nil {
        return nil, err
    }

    resp, err := s.Service.GetObject(&s3.GetObjectInput{
        Bucket: aws.String(os.Getenv("AWS_BUCKET")),
        Key:    aws.String(key),
    })
    if err != nil {
        return nil, err
    }

    return resp, nil
}

func (s *S3Client) GetSignedURL(key string) (string, error) {
    req, _ := s.Service.GetObjectRequest(&s3.GetObjectInput{
        Bucket: aws.String(os.Getenv("AWS_BUCKET")),
        Key:    aws.String(key),
    })

    // Generate the signed URL
    signedURL, err := req.Presign(15 * time.Minute) // Adjust the duration as needed
    if err != nil {
        return "", err
    }

    return signedURL, nil
}
