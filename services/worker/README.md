## Example of messages
Full Content
```json
{
  "specversion": "1.0",
  "id": "12345",
  "type": "example.type",
  "source": "/source/uri",
  "datacontenttype": "application/json",
  "dataschema": "http://schema.registry/schemas/12345",
  "subject": "example.subject",
  "time": "2024-01-27T12:00:00Z",
  "data": {
    "key": "value"
  }
}
```

Only Required Fields Message
```json
{
  "specversion": "1.0",
  "id": "12345",
  "type": "example.type",
  "source": "/source/uri"
}
```

Required Fields and Data Message
```json
{
  "specversion": "1.0",
  "id": "12345",
  "type": "example.type",
  "source": "/source/uri",
  "data": {
    "key": "value"
  }
}
```

Malformed JSON Message
```json
{
  "specversion": "1.0",
  "id": "12345"
  "type": "example.type",
  "source": "/source/uri",
  "data": "key": "value"
}
```

Malformed Fields Message:
```json
{
  "spec_version": "1.0",
  "identifier": "12345",
  "event_type": "example.type",
  "source_uri": "/source/uri",
  "content_type": "application/json",
  "schema": "http://schema.registry/schemas/12345",
  "topic": "example.subject",
  "timestamp": "2024-01-27T12:00:00Z",
  "payload": {
    "key": "value"
  }
}
```