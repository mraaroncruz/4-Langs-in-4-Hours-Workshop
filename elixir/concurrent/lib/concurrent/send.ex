defmodule Concurrent.Send do
  def start do
    parent = self()

    pid = spawn fn ->
      send parent, :hello
    end

    receive do
      :hello ->
        IO.puts("Parent received message")
    end
  end

  def start_linked do
    pid = spawn_link &listen/0

    Process.register(pid, :my_process)
  end

  def listen do
    receive do
      :ping ->
        IO.puts("pong")
      :boom ->
        raise "Boom!"
      message ->
        IO.puts("Don't understand message #{inspect message}. Derp Derp!?>((D")
    end
    listen
  end
end
