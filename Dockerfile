FROM golang:1.24 AS builder
RUN go install github.com/gopherguides/hype/cmd/hype@latest

FROM golang:1.24
COPY --from=builder /go/bin/hype /usr/local/bin/hype
WORKDIR /site
COPY . .
RUN hype blog build
EXPOSE 3000
CMD ["hype", "blog", "serve", "--addr", ":3000"]
