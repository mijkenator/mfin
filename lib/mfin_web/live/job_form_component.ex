defmodule MfinWeb.JobFormComponent do
  use MfinWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  @impl true
  def handle_event(event, params, socket) do

    IO.puts("HE JFC: #{inspect(event)} -> #{inspect(params)}")
    {:noreply, socket}
  end

  defp assign_changeset(assigns, socket) do
    IO.puts("AC JFC: #{inspect(assigns)}")
    changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    socket = socket
             |> assign(:title, assigns[:title])
             |> assign(:changeset, changeset)
  end

end

