defmodule MfinWeb.JobsLive do
  
  use MfinWeb, :live_view
  alias Mfin.Egjob

  def mount(_params, _session, socket), do: {:ok, socket}
  
  def handle_params(_params, _url, socket) do
    {:noreply, assign_jobs(socket)}
  end
  
  defp assign_jobs(socket) do
    assign(socket, :jobs, Egjob.get_all_jobs())
  end
  
  def handle_event("toggle-activeness", assigns, socket) do
    IO.puts("TOGGLE: #{inspect(assigns)}")
    {:noreply, socket}
  end

end
