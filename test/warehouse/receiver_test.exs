defmodule Warehouse.ReceiverTest do
  use ExUnit.Case
  doctest Warehouse.Receiver
  # alias Warehouse.{Package, Receiver}

  # test "receive_and_chunk" do
  #   packages = Package.random_batch(5)
  #   Receiver.receive_and_chunk(packages)
  #   result = :sys.get_state(Receiver)

  #   assert result == %{assignments: []}
  # end
end
