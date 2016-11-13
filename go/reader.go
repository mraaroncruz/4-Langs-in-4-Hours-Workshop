package main

import (
	"bufio"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

const workerCount = 3

type Feed struct {
}

var client = &http.Client{}

func main() {
	urls := getURLs("./sites.txt")
	pushChannel := make(chan string)
	feedChannel := make(chan Feed)
	for i := 0; i < workerCount; i++ {
		worker(pushChannel, feedChannel)
	}
}

func worker(inChan chan string, outChan chan Feed) {
	go func() {
		for url := range inChan {
			res, _ := get(url)
		}
	}()
}

func get(url string) ([]byte, error) {
	res, err = client.Get(url)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err = ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	return body, nil
}

func getURLs(path string) []string {
	file, err := os.Open(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var urls []string
	for scanner.Scan() {
		urls = append(urls, scanner.Text())
	}
	return urls
}
