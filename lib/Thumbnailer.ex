defmodule Thumbnailer do
  use GenServer

  def push(element) do
    GenServer.cast(__MODULE__, {:push, element})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def start_link(initial_elements \\ []) do
    GenServer.start_link(__MODULE__, initial_elements, name: __MODULE__)
  end

  # Callbacks

  @impl true
  def init(_elements) do
    {:ok, %{queue: []}}
  end

  @impl true
  def handle_call(:pop, _from, %{:queue => []} = state) do
    {:reply, nil, state}
  end
  def handle_call(:pop, _from, %{:queue => q} = state) do
    [to_caller | new_q] = q
    {:reply, to_caller, %{state | queue: new_q}}
  end

  @impl true
  def handle_cast({:push, element}, %{:queue => q} = state) do
    new_q = [element | q]
    {:noreply, %{state | queue: new_q} }
  end
end
