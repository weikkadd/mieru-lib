package main

import "C"

//export Hello
func Hello() C.int { return 0 }

func main() {}
