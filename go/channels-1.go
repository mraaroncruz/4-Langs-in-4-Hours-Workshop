package main

import (
	"fmt"
	"math/rand"
	"time"
)

const workerCount = 10
const max = 10000

type Result struct {
	WorkerNumber int
	Result       int
}

func main() {
	resultChan := make(chan Result)
	pushChan := make(chan int)

	var i int

	for i = 0; i < workerCount; i++ {
		startWorker(i, pushChan, resultChan)
	}

	go func() {
		for i = 0; i < max; i++ {
			pushChan <- i
		}
	}()

	var result Result
	for ii := 0; ii < max; ii++ {
		result = <-resultChan
		fmt.Printf("Got result %d from worker %d\n", result.Result, result.WorkerNumber)
	}
}

func startWorker(workerNum int, pullChan chan int, resultChan chan Result) {
	go func() {
		for item := range pullChan {
			simulateWork()
			resultChan <- Result{workerNum, item * item}
		}
	}()
}

func simulateWork() {
	n := time.Duration(rand.Intn(500) + 1)
	time.Sleep(time.Millisecond * n)
}
