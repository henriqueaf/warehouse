defmodule Warehouse.ReceiverTest do
  use ExUnit.Case, async: true
  doctest Warehouse.Receiver
  alias Warehouse.{Package, Receiver}

  setup do
    packages = Package.random_batch(5)
    %{packages: packages}
  end

  describe "#receive_packages" do
    test "receive all packages", %{packages: packages} do
      Receiver.receive_packages(packages)
      :timer.sleep :rand.uniform(500) # wait until packages are delivered

      %{delivered_packages: delivered_packages, assignments: assignments} = :sys.get_state(Receiver)
      assert delivered_packages |> Enum.sort_by(&(&1.id)) == packages |> Enum.sort_by(&(&1.id))
      assert Enum.empty?(assignments)
    end
  end
end
