defmodule Warehouse.Receiver do
  use GenServer
  alias Warehouse.Deliverator

  @moduledoc """
  Warehouse.Receiver will store all assignments.
  """

  def start_link do
    # Will be used just one for the whole application, so we use 'name: __MODULE__' to generate
    # only one Receiver GenServer and it will have the module name 'Warehouse.Receiver'.
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Initiates assignments with empty list.

  ## Examples

    iex> :sys.get_state(Warehouse.Receiver)
    %{assignments: []}

  """
  def init(_) do
    state = %{
      assignments: [],
    }

    {:ok, state}
  end

  def receive_and_chunk(packages) do
    packages
    |> Enum.chunk_every(5)
    |> Enum.each(&receive_packages/1)
  end

  def receive_packages(packages) do
    GenServer.cast(__MODULE__, {:receive_packages, packages})
  end

  def handle_cast({:receive_packages, packages}, state) do
    IO.puts "received #{Enum.count(packages)} packages"
    {:ok, deliverator} = Deliverator.start()
    Process.monitor(deliverator) # receives a message when the process Deliverator goes down
    state = assign_packages(state, packages, deliverator)
    Deliverator.deliver_packages(deliverator, packages)
    {:noreply, state}
  end

  # handle_info is used to receive messages from other processes
  def handle_info({:package_delivered, package}, state) do
    IO.puts "package #{inspect package} was delivered"
    delivered_assignments =
      state.assignments
      |> Enum.filter(fn({assigned_package, _pid}) -> assigned_package == package end)

    assignments = state.assignments -- delivered_assignments
    state = %{state | assignments: assignments}

    {:noreply, state}
  end

  # handle the message DOWN normal from deliverator
  def handle_info({:DOWN, _ref, :process, deliverator, :normal}, state) do
    IO.puts "deliverator #{inspect deliverator} completed the mission and terminated"
    {:noreply, state}
  end

  # handle all unknow messages from deliverator when it goes DOWN
  def handle_info({:DOWN, _ref, :process, deliverator, reason}, state) do
    IO.puts "deliverator #{inspect deliverator} went down. details: #{inspect reason}"
    failed_assignments = filter_by_deliverator(deliverator, state.assignments)
    failed_packages = failed_assignments |> Enum.map(fn({ package, _pid }) -> package end)

    assignments = state.assignments -- failed_assignments
    state = %{state | assignments: assignments}
    receive_packages(failed_packages)
    {:noreply, state}
  end

  defp assign_packages(state, packages, deliverator) do
    new_assignments = packages |> Enum.map(fn(package) -> {package, deliverator} end)
    assignments = state.assignments ++ new_assignments
    %{state | assignments: assignments}
  end

  defp filter_by_deliverator(deliverator, assignments) do
    assignments
    |> Enum.filter(fn({ _package, assigned_deliverator }) -> assigned_deliverator == deliverator end)
  end
end
