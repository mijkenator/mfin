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
    
    case params["id"] do
      "0" ->
        case Mfin.Egjob.create_job(Map.delete(params, "id")) do
          {:ok, _} ->
            {:noreply, 
              socket
                |> put_flash(:info, "New record created!")
                |> push_navigate(to: "/jbs", replace: true)
            }
          err ->
            IO.puts("Create error: #{inspect(err)} ")
            {:noreply, 
              socket
                |> put_flash(:info, "Not created!")
            }
        end
      _ ->
        {num, _} = Mfin.Egjob.update_opt(
          String.to_integer(params["id"]), 
          Map.delete(params, "id")
        )
        socket = case num do
          1 ->
            socket
            |> put_flash(:info, "Saved new info successfully!")
            #|> push_event("js-exec", %{to: "#jobs-modal", attr: "data-cancel"})
            |> push_navigate(to: "/jbs", replace: true)
          _ ->
            socket
            |> put_flash(:error, "Not saved!")
        end
        {:noreply, socket}
    end
  end
  def handle_event(event, params, socket) do

    IO.puts("HE JFC: #{inspect(event)} -> #{inspect(params)}")
    {:noreply, socket}
  end

  defp assign_changeset(assigns, socket) do
    IO.puts("AC JFC: #{inspect(assigns)}")
    #changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    changeset = case assigns[:id] do
      "0" ->
        %{
          "id" => 0
        }
      bin_id ->
        Mfin.Egjob.get_job_byid(String.to_integer(bin_id))
          |> Map.from_struct
          |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end) 
          |> Enum.into(%{}) 
    end
    
    IO.puts("AC CHANGESET: #{inspect(changeset)}")
    socket
      |> assign(:title, assigns[:title])
      |> assign(:id, assigns[:id] )
      |> assign(:changeset, changeset)
  end

end

