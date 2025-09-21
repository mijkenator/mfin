defmodule MfinWeb.BlogLive do
  
  use MfinWeb, :live_view
  alias Mfin.Blog
  require Logger

  def mount(_params, _session, socket) do 
    IO.puts("BLmount: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    {:ok, socket}
  end
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
    IO.puts("JLHP: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    case params["action"] do
      nil ->
        {:noreply,
          socket
          #|> parse_params(params)
          |> assign_blog()
        }
      action ->  
        socket = socket
        |> assign(:live_action, action)
        |> assign(:job_id, params["id"])
        |> assign(:changeset, Mfin.Egjob.get_job_byid(String.to_integer(params["id"])))
        {:noreply, assign_blog(socket)}
    end
  end

  defp assign_blog(socket) do
    params = %{}
    socket
    |> assign(:blog, Blog.get_all_posts(params))
  end
  
  def handle_event("toggle-activeness", assigns, socket) do
    IO.puts("POST TOGGLE: #{inspect(assigns)}")
    Blog.toggle_post_status(String.to_integer(assigns["id"]))
    {:noreply, assign_blog(socket)}
  end
  
end

