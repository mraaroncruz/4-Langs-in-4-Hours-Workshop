defmodule Concurrent do
  @worker_count 10
  @max_wait     200
  @job_count    500

  def start do
    parent = self()

    # Start workers
    workers =
      Enum.to_list(0..@worker_count)
      |> Enum.map(fn _n ->
        spawn fn ->
          start_worker(parent)
        end
      end)
    # Setup jobs
    jobs = Enum.to_list(1..@job_count)

    # Start run loop
    results = run(jobs, [])

    # Kill workers
    Enum.each workers, fn pid -> send pid, :done end

    # Print sorted results
    Enum.each(Enum.sort(results), &IO.puts/1)

    IO.puts("Done with work")
  end

  defp run([job | rest], results) do
    receive do
      # Listen for workers to be ready and send their first job
      {:ready, pid} ->
        send pid, {:work, job}
        run(rest, results)

      # Receive a result
      # add it to the results list
      # and send a new one to ready worker
      {:result, pid, result} ->
        IO.puts("Worker #{inspect pid} sent #{result}")
        send pid, {:work, job}
        results = [result | results]
        run(rest, results)
    end
  end
  defp run([], results), do: results

  defp start_worker(parent) do
    # Let'em know we're ready
    send parent, {:ready, self()}
    # Start work
    work_loop(parent)
  end

  defp work_loop(parent) do
    me = self()
    receive do
      {:work, n} ->
        res = work(n)
        send parent, {:result, me, res}
        work_loop(parent)
      :done ->
        IO.puts("Worker #{inspect me} done...")
    end
  end

  defp work(n) do
    rand_int = :crypto.rand_uniform(1,@max_wait)
    :timer.sleep(rand_int)
    n * n
  end
end
