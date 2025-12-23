FROM golang:1.24-alpine AS builder

RUN apk update && apk add --no-cache ca-certificates git tzdata
WORKDIR /app
COPY . .
RUN go build -o app ./cmd/app/main.go

FROM alpine:3.18
RUN apk add --no-cache ca-certificates tzdata && \
    mkdir -p /app/logs && \
    addgroup -g 1000 app && \
    adduser -u 1000 -G app -s /bin/sh -D app

WORKDIR /app
COPY --from=builder /app/app .
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER app
EXPOSE 8080
ENTRYPOINT ["./app"]
