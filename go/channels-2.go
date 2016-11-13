package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const (
	workerCount = 10
	max         = 10000
	waitMax     = 500
)

type Result struct {
	WorkerNumber int
	Result       int
}

func main() {
	resultChan := make(chan Result)
	pushChan := make(chan int)

	wg := &sync.WaitGroup{}
	// Tell waitgroup how many jobs you're running
	wg.Add(max)

	// Syncronize when you are done with work
	go func() {
		wg.Wait()
		fmt.Println("Everything done...")
		fmt.Println("closing Worker pull channel")
		close(pushChan)
		fmt.Println("closing Result channel")
		close(resultChan)
	}()

	// start workerCount amount of workers
	for i := 0; i < workerCount; i++ {
		startWorker(i, wg, pushChan, resultChan)
	}

	// Send work to workers
	// when worker is ready, it will pull off the queue (channel)
	go func() {
		for n := 0; n < max; n++ {
			pushChan <- n
		}
	}()

	// Iterate over results until channel is closed
	for result := range resultChan {
		fmt.Printf("Got result %d from worker %d\n", result.Result, result.WorkerNumber)
	}
	fmt.Println("Result channel closed and we're exiting")
}

func startWorker(workerNum int, wg *sync.WaitGroup, pullChan chan int, resultChan chan Result) {
	// don't block
	go func() {
		// pull items off queue until channel is closed
		// then just exit
		for item := range pullChan {
			simulateWork()
			resultChan <- Result{workerNum, item * item}
			wg.Done()
		}
		fmt.Printf("Worker %d exiting...\n", workerNum)
	}()
}

func simulateWork() {
	n := time.Duration(rand.Intn(waitMax) + 1)
	time.Sleep(time.Millisecond * n)
}
