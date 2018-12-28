defmodule Warehouse.Deliverator do
  use GenServer
  alias Warehouse.Receiver

  def start do
    GenServer.start(__MODULE__, [])
  end

  # Default required implementation of 'init' function
  def init(args) do
    {:ok, args}
  end

  @doc """
  Method that delivers all packages passed by parameter and the exit the Deliverator Process.

  > packages = Warehouse.Package.random_batch(2)
  > {:ok, pid} = Warehouse.Deliverator.start
  > Warehouse.Deliverator.deliver_packages(pid, packages)
  > Process.alive?(pid)
  false

  """
  def deliver_packages(pid, packages) do
    GenServer.cast(pid, {:deliver_packages, packages})
  end

  def handle_cast({:deliver_packages, packages}, state) do
    deliver(packages)
    {:noreply, state}
  end

  def deliver([]), do: send(Receiver, {:deliverator_idle, self()}) # Process.exit(self(), :normal)
  def deliver([package | remaining_packages]) do
    IO.puts "Deliverator #{inspect self()} delivering #{inspect package}"
    # make_delivery()

    # send() is used to send message to other processes. (Receiver)
    send(Receiver, {:package_delivered, package})
    deliver(remaining_packages)
  end

  defp make_delivery do
    :timer.sleep :rand.uniform(1_000)
    maybe_crash()
  end

  defp maybe_crash do
    crash_factor = :rand.uniform(100)
    IO.puts "Crash factor: #{crash_factor}"
    if crash_factor > 60, do: raise "oh no! going down"
  end
end
