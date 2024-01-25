package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func routerServeHTTP(req *http.Request) *httptest.ResponseRecorder {
	router := setupRouter()

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	return w
}

func TestPingRoute(t *testing.T) {

	req, _ := http.NewRequest("GET", "/ping", nil)
	w := routerServeHTTP(req)
	assert.Equal(t, 200, w.Code)
	assert.Contains(t, w.Body.String(), "pong")
}

func TestSuccessRegisterEvent(t *testing.T) {
	var e CloudEvent = CloudEvent{
		ID:          "123",
		SpecVersion: "1",
		Type:        "event",
		Source:      "internal",
	}

	b, _ := json.Marshal(e)
	buf := bytes.NewBuffer(b)

	req, _ := http.NewRequest("POST", "/register", buf)
	w := routerServeHTTP(req)

	assert.Equal(t, 202, w.Code)

	var response CloudEvent
	json.Unmarshal(w.Body.Bytes(), &response)
	assert.Equal(t, response, e)
}

func TestInvalidEvent(t *testing.T) {
	var invalidEvent map[string]interface{} = map[string]interface{}{
		"wrong": "wrong",
	}

	b, _ := json.Marshal(invalidEvent)
	buf := bytes.NewBuffer(b)

	req, _ := http.NewRequest("POST", "/register", buf)
	w := routerServeHTTP(req)

	assert.Equal(t, 400, w.Code)
}
