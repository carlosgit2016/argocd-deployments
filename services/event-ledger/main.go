package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"gopkg.in/go-playground/validator.v8"
)

var logger *zap.Logger
var validate *validator.Validate

func init() {
	rawJSON := []byte(`{
		"level": "debug",
		"encoding": "json",
		"outputPaths": ["stdout", "/tmp/logs"],
		"errorOutputPaths": ["stderr"],
		"encoderConfig": {
		  "messageKey": "message",
		  "levelKey": "level",
		  "levelEncoder": "lowercase"
		}
	  }`)

	var cfg zap.Config
	if err := json.Unmarshal(rawJSON, &cfg); err != nil {
		fmt.Errorf("zap Logger configuration error %s", err.Error())
	}

	logger = zap.Must(cfg.Build())
	defer logger.Sync()

	// Struct validator to cloud events
	config := &validator.Config{TagName: "validate"}
	validate = validator.New(config)
}

func ping(c *gin.Context) {
	timeNow := time.Now().Unix()
	logger.Debug(fmt.Sprintf("pong %s", fmt.Sprint(timeNow)), zap.String("source", c.RemoteIP()))
	c.String(http.StatusOK, fmt.Sprintf("pong %s", fmt.Sprint(timeNow)))
}

func registerEvent(c *gin.Context) {
	var event CloudEvent

	if err := c.BindJSON(&event); err != nil {
		logger.Error("invalid json body request", zap.Any("error", err))
		c.IndentedJSON(http.StatusBadRequest, gin.H{"message": "Invalid event"})
		return
	}

	if errs := validate.Struct(event); errs != nil {
		logger.Error("invalid event", zap.Any("error", errs))
		c.IndentedJSON(http.StatusBadRequest, errs)
		return
	}

	logger.Info(fmt.Sprintf("processing event %s", event.ID), zap.Any("event", event))
	c.IndentedJSON(http.StatusAccepted, event)
}

func setupRouter() *gin.Engine {
	router := gin.New()

	router.GET("/ping", ping)
	router.POST("/register", registerEvent)
	router.NoRoute(func(c *gin.Context) {
		logger.Info(fmt.Sprintf("%v path %s Not Found", http.StatusNotFound, c.Request.URL.Path), zap.String("source", c.RemoteIP()))
		c.String(http.StatusNotFound, fmt.Sprintf("%v path %s Not Found", http.StatusNotFound, c.Request.URL.Path))
	})
	return router
}

func main() {
	router := setupRouter()

	if err := router.Run(":80"); err != nil {
		logger.Error("error initializing webserver", zap.String("error", err.Error()))
	}
}
