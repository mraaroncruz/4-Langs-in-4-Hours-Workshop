defmodule Concurrent do
  @worker_count 1000
  @max_wait     2000
  @job_count    100000

  def start do
    parent = self()
    workers =
      Enum.to_list(0..@worker_count)
      |> Enum.map(fn _n ->
        spawn fn ->
          start_worker(parent)
        end
      end)
    jobs = Enum.to_list(1..@job_count)
    run(jobs)
    Enum.each workers, fn pid -> send pid, :done end
    IO.puts("Done with work")
  end

  defp run([job | rest]) do
    receive do
      {:ready, pid} ->
        send pid, {:work, job}
      {:result, pid, result} ->
        IO.puts("Worker #{inspect pid} sent #{result}")
        send pid, {:work, job}
    end
    run(rest)
  end
  defp run([]), do: nil

  defp start_worker(parent) do
    send parent, {:ready, self()}
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
        IO.puts("Worker #{me} done...")
    end
  end

  defp work(n) do
    rand_int = :crypto.rand_uniform(1,@max_wait)
    :timer.sleep(rand_int)
    n * n
  end
end
