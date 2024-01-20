package main

import "time"

type CloudEvent struct {
	SpecVersion     string      `json:"specversion" validate:"required"`
	ID              string      `json:"id" validate:"required"`
	Type            string      `json:"type" validate:"required"`
	Source          string      `json:"source" validate:"required"`
	DataContentType string      `json:"datacontenttype,omitempty"`
	DataSchema      string      `json:"dataschema,omitempty"`
	Subject         string      `json:"subject,omitempty"`
	Time            *time.Time  `json:"time,omitempty"`
	Data            interface{} `json:"data,omitempty"`
}
