package main

import "fmt"

func helloworld() string {
	return "Hello World!!"
}

func main() {
	fmt.Println(helloworld())
}

func getExampleTable(pid string) [][]interface{} {
	switch pid {
	case "12345":
		return [][]interface{}{
			[]interface{}{10},
			{10},
		}
	case "10002":
		return [][]interface{}{
			[]interface{}{22},
			{22},
		}
	}
	return nil
}
