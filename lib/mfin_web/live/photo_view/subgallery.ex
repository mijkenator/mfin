defmodule MfinWeb.PhotoView.Subgallery do
  use MfinWeb, :live_view

  alias MfinWeb.GalleryComponent
  require Logger

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket, page: 1)
    # on initial load it'll return false,
    # then true on the next.
    Logger.debug("SUBGALLERY: #{inspect(params)}")
    if connected?(socket) do
      get_images(socket, params)
    else
      socket
    end

    {:ok,
      socket |> assign(:month, params["month"]) |> assign(:year, params["year"]),
      temporary_assigns: [images: []]
    }
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    Logger.debug("MPI load-more #{inspect(assigns)}")
    %{month: m, year: y} = assigns
    {:noreply, assign(socket, page: assigns.page + 1) |> get_images(%{"month" => m, "year" => y})}
  end

  defp get_images(%{assigns: %{page: page}} = socket, params) do
    socket
    |> assign(page: page)
    |> assign(images: images(page, params))
  end

  defp images(page, %{"month" =>  m, "year" =>  y} = params) do
    Logger.debug("Images page: #{inspect(page)}")
    offset = (page-1) * 100
    query = "/phtv/"
    Mfin.Photolib.get_subgallery(String.to_integer(m), String.to_integer(y), %{limit: 100, offset: offset})
    #|> Enum.map(&({"#{query}#{&1}", "#{query}#{&1}"}))
    |> Enum.map(fn {pn, n, meta} -> {"#{query}#{pn}", "#{query}#{n}", meta} end)
  end
end
