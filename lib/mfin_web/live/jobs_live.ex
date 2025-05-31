defmodule MfinWeb.JobsLive do
  
  use MfinWeb, :live_view
  alias Mfin.Egjob

  def mount(_params, _session, socket), do: {:ok, socket}
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
    case params["action"] do
      nil ->
        {:noreply, assign_jobs(socket)}
      action ->  
        socket = socket
        |> assign(:live_action, action)
        |> assign(:job_id, params["id"])
        |> assign(:changeset, Mfin.Egjob.get_job_byid(String.to_integer(params["id"])))
        {:noreply, assign_jobs(socket)}
    end
  end
  
  defp assign_jobs(socket) do
    assign(socket, :jobs, Egjob.get_all_jobs())
  end
  
  def handle_event("toggle-activeness", assigns, socket) do
    IO.puts("TOGGLE: #{inspect(assigns)}")
    Mfin.Egjob.toggle_job(String.to_integer(assigns["id"]))
    {:noreply, assign_jobs(socket)}
  end

end
