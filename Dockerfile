FROM golang:1.25 AS builder
RUN go install github.com/gopherguides/hype/cmd/hype@v0.8.0

FROM golang:1.25
COPY --from=builder /go/bin/hype /usr/local/bin/hype
WORKDIR /site
COPY . .
RUN hype blog build
EXPOSE 3000
CMD ["hype", "blog", "serve", "--addr", ":3000"]
