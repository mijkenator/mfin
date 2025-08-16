defmodule MfinWeb.JobsLive do
  
  use MfinWeb, :live_view
  alias Mfin.Egjob
  alias MfinWeb.Forms.SortingForm
  alias MfinWeb.Forms.FilterForm
  require Logger

  def mount(_params, _session, socket) do 
    IO.puts("JLmount: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    {:ok, socket}
  end
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
    IO.puts("JLHP: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    case params["action"] do
      nil ->
        {:noreply,
          socket
          |> parse_params(params)
          |> assign_jobs()
        }
      action ->  
        socket = socket
        |> assign(:live_action, action)
        |> assign(:job_id, params["id"])
        |> assign(:changeset, Mfin.Egjob.get_job_byid(String.to_integer(params["id"])))
        {:noreply, assign_jobs(socket)}
    end
  end

  def handle_info({:update, opts}, socket) do
        params = merge_and_sanitize_params(socket, opts)
        Logger.debug("HI params: #{inspect(params)}")
        path = ~p"/jbs?#{params}"
        {:noreply, push_patch(socket, to: path, replace: true)}
    end
  
  defp assign_jobs(socket) do
    params = merge_and_sanitize_params(socket)
    socket
    |> assign(:jobs, Egjob.get_all_jobs(params))
  end
  
  def handle_event("toggle-activeness", assigns, socket) do
    IO.puts("TOGGLE: #{inspect(assigns)}")
    Mfin.Egjob.toggle_job(String.to_integer(assigns["id"]))
    {:noreply, assign_jobs(socket)}
  end
  def handle_event("filter-reset-click", _assigns, socket) do
    path = ~p"/jbs"
    socket = socket
      |> reset_filter()
    {:noreply, push_navigate(socket, to: path, replace: true)}
  end
  def handle_event("select_checkbox", assigns, socket) do
    IO.puts("SC: #{inspect(assigns)}")
    {:noreply, socket}
  end

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
     case socket.assigns do 
       %{sorting: sorting, filter: filter} ->
          %{}
           |> Map.merge(sorting)
           |> Map.merge(filter)
           |> Map.merge(overrides)
           |> Enum.reject(fn {_key, value} -> is_nil(value) end)
           |> Map.new()
       _ ->
          %{}
           |> Map.merge(overrides)
           |> Enum.reject(fn {_key, value} -> is_nil(value) end)
           |> Map.new()

     end
  end

  defp parse_params(socket, params) do
      Logger.debug "PPPPPPPPPPPPPPPP1"
    with {:ok, sorting_opts} <- SortingForm.parse(params),
         {:ok, filter_opts} <- FilterForm.parse(params) do
        Logger.debug "PPPPPPPPPPPPPPPP2"
        socket
        |> assign_filter(filter_opts)
        |> assign_sorting(sorting_opts)
      else
        _error ->
          socket
          |> assign_filter() 
          |> assign_sorting()
      end
  end

  defp assign_sorting(socket, overrides \\ %{}) do
    opts = Map.merge(SortingForm.default_values(), overrides)
    assign(socket, :sorting, opts)
  end

  defp assign_filter(socket, overrides \\ %{}) do
      assign(socket, :filter, FilterForm.default_values(overrides))
  end

  defp reset_filter(socket) do
      assign(socket, :filter, %{})
  end

end
