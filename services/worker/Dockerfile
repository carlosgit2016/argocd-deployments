FROM golang:alpine3.19 as base

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
RUN go build -o main

FROM scratch

ENV GIN_MODE release
COPY --from=base /app/main /main

CMD [ "/main" ]