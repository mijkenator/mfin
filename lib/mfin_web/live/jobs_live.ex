defmodule MfinWeb.JobsLive do
  
  use MfinWeb, :live_view
  alias Mfin.Egjob
  alias MfinWeb.Forms.SortingForm
  require Logger

  def mount(_params, _session, socket), do: {:ok, socket}
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
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

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
      %{sorting: sorting} = socket.assigns

      %{}
       |> Map.merge(sorting)
       |> Map.merge(overrides)
       |> Enum.reject(fn {_key, value} -> is_nil(value) end)
       |> Map.new()
  end

  defp parse_params(socket, params) do
      Logger.debug "PPPPPPPPPPPPPPPP1"
      with {:ok, sorting_opts} <- SortingForm.parse(params) do
        Logger.debug "PPPPPPPPPPPPPPPP2"
        socket
        |> assign_sorting(sorting_opts)
      else
        _error ->
          socket
          |> assign_sorting()
      end
  end

  defp assign_sorting(socket, overrides \\ %{}) do
    opts = Map.merge(SortingForm.default_values(), overrides)
    assign(socket, :sorting, opts)
  end

end
