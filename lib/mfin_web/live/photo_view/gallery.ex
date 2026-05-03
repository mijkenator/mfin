defmodule MfinWeb.PhotoView.Gallery do
  use MfinWeb, :live_view

  alias MfinWeb.GalleryComponent
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, page: 1)
    # on initial load it'll return false,
    # then true on the next.
    Logger.debug("MPI1")
    if connected?(socket) do
      Logger.debug("MPI100")
      get_images(socket)
    else
      Logger.debug("MPI101")
      socket
    end

    Logger.debug("MPI2")
    {:ok,
      socket,
      temporary_assigns: [images: []]
    }
  end

  @impl true
  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    Logger.debug("MPI load-more #{inspect(assigns)}")
    {:noreply, assign(socket, page: assigns.page + 1) |> get_images()}
  end

  defp get_images(%{assigns: %{page: page}} = socket) do
    socket
    |> assign(page: page)
    |> assign(images: images())
  end

  defp images() do
    Logger.debug("Images gallery preview")
    query = "/phtv/"
    Mfin.Photolib.get_gallery_preview()
    #|> Enum.map(&({"#{query}#{&1}", "#{query}#{&1}"}))
    |> Enum.map(fn {pn, n, text} -> {"#{query}#{pn}", "#{query}#{n}", text} end)
  end
end

