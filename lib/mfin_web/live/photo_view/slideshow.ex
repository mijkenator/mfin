defmodule MfinWeb.PhotoView.Slideshow do
  use MfinWeb, :live_view

  alias MfinWeb.GalleryComponent
  require Logger

  @impl true
  def mount(params, _session, socket) do
    socket = assign(socket, page: 0)
    # on initial load it'll return false,
    # then true on the next.
    Logger.debug("SUBGALLERY: #{inspect(params)}")
    #if connected?(socket) do
    #  get_images(socket, params)
    #else
    #  socket
    #end

    {:ok,
      socket 
        |> assign(:month, params["month"]) 
        |> assign(:year, params["year"])
        |> assign(:pcount, 0),
      temporary_assigns: [images: []],
      layout: {MfinWeb.Layouts, :slideshow}
    }
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    Logger.debug("MPI load-more #{inspect(assigns)}")
    %{month: m, year: y} = assigns
    {:noreply, assign(socket, page: assigns.page + 1) |> get_images(%{"month" => m, "year" => y})}
    #{:noreply, socket}
  end

  defp get_images(%{assigns: %{page: page}} = socket, params) do
    imgs = images(page, params)
    socket
    |> assign(page: page)
    |> assign(images: imgs)
    |> then(fn s -> 
        if page == 1, do: assign(s, pcount: length(imgs)), else: s
       end)
  end

  defp images(page, %{"month" =>  m, "year" =>  y} = params) do
    Logger.debug("Images page: #{inspect(page)}")
    offset = case page do
      0 -> 0
      _ -> (page-1) * 100
    end
    query = "/phtv/"
    case {m, y} do
      {"undefined", "undefined"} ->
        Mfin.Photolib.get_undef_subgallery(%{limit: 100, offset: offset})
        |> Enum.map(fn {pn, n, meta} -> {"#{query}#{pn}", "#{query}#{n}", meta} end)
      _ ->
        Mfin.Photolib.get_subgallery(String.to_integer(m), String.to_integer(y), %{limit: 100, offset: offset})
        |> Enum.map(fn {pn, n, meta} -> {"#{query}#{pn}", "#{query}#{n}", meta} end)
    end
  end
end
