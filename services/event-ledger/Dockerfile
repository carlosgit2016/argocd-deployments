FROM golang:1.20-alpine3.19 as build

WORKDIR /app

COPY . .

RUN go test ./...
RUN go install
RUN go build -o main

FROM alpine:3.19

EXPOSE 80
ENV GIN_MODE release

COPY --from=build /app/main .

CMD [ "./main" ]