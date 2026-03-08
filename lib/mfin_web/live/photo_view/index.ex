defmodule MfinWeb.PhotoView.Index do
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

  defp images do
    url = ""
    query = "/phtv/"
    ~W(
      01f366d9-afa0-44fa-beda-d92e5e655254_p_200.jpg 0A1B2825-F394-4381-B84D-0338C9DF7216_p_200.jpg 
      4a0e1f77-1b92-4022-89ee-d9058616bb9c_p_200.jpg 01f366d9-afa0-44fa-beda-d92e5e655254_p_200.jpg
      5e7ba9fa-faf6-40b0-bfaa-1c24c206e087_p_200.jpg 0A2E4317-C0A9-475B-A59F-BA10816F242A_p_200.jpg
      0A0D58FA-8321-4600-B9AF-5F68F8963AC3_p_200.jpg 6d4c32b4-c0ec-4412-bc01-11cef10f675a_p_200.jpg
      0A3BA3EA-E656-43D1-BB9A-B84676E14E61_p_200.jpg 6ecd045a-a307-4712-9535-3d4ad22b508e_p_200.jpg
      0A0F19DF-E898-4A30-92F3-FD7C05686ED2_p_200.jpg 2c7038c7-ce3e-4aef-82c2-0f1b2f4f2d88_p_200.jpg
      8f61122e-04c1-48c5-850b-1cccdf9d1091_p_200.jpg
    )
    |> Enum.map(&("#{query}#{&1}"))
    |> Enum.shuffle()
  end
end
