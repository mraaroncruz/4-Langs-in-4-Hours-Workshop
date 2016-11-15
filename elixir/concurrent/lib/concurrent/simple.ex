defmodule Concurrent.Simple do
  def simple do
    spawn fn ->
      raise "Boom!"
    end
  end

  def linked do
    spawn_link fn ->
      raise "Boom!"
    end
  end
end
