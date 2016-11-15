defmodule Concurrent.Supervised do
  def start_link do
    # This isn't supervised :/
    pid = spawn &Concurrent.Send.listen/0
    Process.register(pid, :my_process)
    {:ok, pid}
  end
end
