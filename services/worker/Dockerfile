FROM golang:alpine3.19 as base

WORKDIR /app

COPY . .

# RUN go test ./...
RUN go install
RUN go build -o main.go

FROM alpine:3.19

ENV GIN_MODE release
COPY --from=base /app/main.go .

CMD [ "./main.go" ]