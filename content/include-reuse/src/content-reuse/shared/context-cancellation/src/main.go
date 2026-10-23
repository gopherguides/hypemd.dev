package main

import (
	"context"
	"fmt"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	fmt.Println("Canceled:", ctx.Err())
}
