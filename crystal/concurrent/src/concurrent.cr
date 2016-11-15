require "./concurrent/*"

module Concurrent
  class Example
    def example(worker_count = 10, job_count = 10000)
      # push to the workers
      push_chan    = Channel(Int32).new
      # get results back
      receive_chan = Channel(Array(Int32)).new

      # Start your workers
      (0...worker_count).each do |n|
        start_worker(n, push_chan, receive_chan)
      end

      # Push in jobs in the background
      spawn do
        (1..job_count).each do |n|
          push_chan.send(n)
        end
      end

      # Receive the results
      (1..job_count).each do |_n|
        res = receive_chan.receive
        puts("Received #{res[1]} from #{res[0]}")
      end

      # Leave when done. Don't close channels because I don't know how :)
    end

    def start_worker(n, pull_chan, push_chan)
      # Start worker in the background and process jobs
      spawn do
        while true
          sleep(rand * 4)
          res = pull_chan.receive
          push_chan.send([n, res * res])
        end
      end
    end
  end
end

Concurrent::Example.new.example(100, 100000)
