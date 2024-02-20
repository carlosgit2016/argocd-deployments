FROM golang:1.20-alpine3.19 as build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main

FROM alpine:3.19

EXPOSE 80
ENV GIN_MODE release

WORKDIR /app
COPY --from=build /app/main /main

# Security <3
RUN adduser -D goman && \
    chown -R goman:goman /app
USER goman

CMD [ "/main" ]