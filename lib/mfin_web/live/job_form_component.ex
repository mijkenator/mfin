defmodule MfinWeb.JobFormComponent do
  use MfinWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  # const event = new CustomEvent('phx:js-exec', {detail: { to: "#jobs-modal", arrt: 'data-cancel' }});
  # window.dispatchEvent(event)
  @impl true
  def handle_event("save", params, socket) do
    IO.puts("HE SAVE:  #{inspect(params)}")

    Mfin.Egjob.update(
      String.to_integer(params["id"]), 
      Map.delete(params, "id")
    )

    socket = socket
      |> put_flash(:info, "Saved new info successfully!")
      #|> push_event("js-exec", %{to: "#jobs-modal", attr: "data-cancel"})
      |> push_navigate(to: "/jbs", replace: true)
    {:noreply, socket}
  end
  def handle_event(event, params, socket) do

    IO.puts("HE JFC: #{inspect(event)} -> #{inspect(params)}")
    {:noreply, socket}
  end

  defp assign_changeset(assigns, socket) do
    IO.puts("AC JFC: #{inspect(assigns)}")
    #changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    changeset = Mfin.Egjob.get_job_byid(String.to_integer(assigns[:id]))
      |> Map.from_struct
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end) 
      |> Enum.into(%{}) 
    
    IO.puts("AC CHANGESET: #{inspect(changeset)}")
    socket
      |> assign(:title, assigns[:title])
      |> assign(:name, "lalalall-okokok")
      |> assign(:changeset, changeset)
  end

end

