package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	rabbitmq "github.com/wagslane/go-rabbitmq"
	"go.uber.org/zap"
	"gopkg.in/go-playground/validator.v8"
)

var conn *rabbitmq.Conn
var logger *zap.Logger
var validate *validator.Validate

func init() {
	zapConfig := []byte(`{
		"level": "debug",
		"encoding": "json",
		"outputPaths": ["stdout"],
		"errorOutputPaths": ["stderr"],
		"encoderConfig": {
		  "messageKey": "message",
		  "levelKey": "level",
		  "levelEncoder": "lowercase"
		}
	}`)
	var cfg zap.Config
	if err := json.Unmarshal(zapConfig, &cfg); err != nil {
		fmt.Print(fmt.Errorf("zap Logger configuration error %s", err.Error()))
	}
	logger = zap.Must(cfg.Build())
	defer logger.Sync()

	// RabbitMQ connection
	var err error
	conn, err = rabbitmq.NewConn(
		rabbitMQConnectionString(),
	)
	if err != nil {
		logger.Fatal(fmt.Sprintf("Failed establishing connection with rabbitmq"), zap.String("error", err.Error()))
	}

	// Struct validator
	config := &validator.Config{TagName: "validate"}
	validate = validator.New(config)
}

func is_prod() bool {
	return os.Getenv("ENVIRONMENT") == "production"
}

func rabbitMQConnectionString() string {
	rabbitmq_user := os.Getenv("RABBITMQ_USER")
	rabbitmq_host := os.Getenv("RABBITMQ_HOST")
	var password string

	if is_prod() {
		// TBD
		password = "dOUc530,\\e7="
	} else {
		password = "bitnami"
	}

	return fmt.Sprintf("amqp://%s:%s@%s", rabbitmq_user, password, rabbitmq_host)
}

// Process message in its arrival, could ack or nack
func processMessage(d rabbitmq.Delivery) rabbitmq.Action {
	var message CloudEvent
	if err := json.Unmarshal(d.Body, &message); err != nil {
		logger.Error(fmt.Sprintf("Error parsing message %s", d.MessageId), zap.String("error", err.Error()))
		return rabbitmq.NackDiscard
	}

	if errs := validate.Struct(message); errs != nil {
		logger.Error("Failed to validate message", zap.Any("errors", errs))
		return rabbitmq.NackDiscard
	}

	logger.Debug(fmt.Sprintf("Message processed successfully %s, routing_key: %s", message.ID, d.RoutingKey), zap.Any("message", message))

	return rabbitmq.Ack
}

func main() {
	defer conn.Close()

	consumer, err := rabbitmq.NewConsumer(
		conn,
		processMessage,
		"events",
		rabbitmq.WithConsumerOptionsRoutingKey("my_routing_key"),
		rabbitmq.WithConsumerOptionsExchangeName("events"),
		rabbitmq.WithConsumerOptionsExchangeDeclare,
	)

	if err != nil {
		logger.Fatal("Failed creating new consumer", zap.String("error", err.Error()))
	}

	defer consumer.Close()

	// block main thread
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)

	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigs
		logger.Info(sig.String())
		done <- true
	}()

	logger.Info("awaiting signal")
	<-done
	logger.Info("Stopping consumer")

}
