FROM golang:1.23.2-alpine AS builder


# All these steps will be cached
RUN mkdir /app
WORKDIR /app

RUN apk update && apk add --no-cache git ca-certificates make

COPY go.mod .
COPY go.sum .

# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

# COPY the source code as the last step
COPY . .

# Build the binary
RUN CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    make build

FROM scratch

WORKDIR /app
# Copy the Pre-built binary file from the previous stage

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/bin/app /app/app

# Command to run the executable
CMD ["/app/app"]