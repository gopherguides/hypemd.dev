package main

import (
	"flag"
	"fmt"
)

func main() {
	flag.CommandLine = flag.NewFlagSet("greet", flag.ExitOnError)
	name := flag.String("name", "World", "name to greet")
	flag.Parse()
	fmt.Printf("Hello, %s!\n", *name)
}
