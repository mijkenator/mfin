defmodule MfinWeb.GalleryComponent do
  use MfinWeb, :live_component

  defp random_id, do: Enum.random(1..1_000_000)

  def render(assigns) do
    ~H"""
    <div>
      <div
        id="infinite-scroll-body"
        phx-update="append"
        class="grid grid-cols-3 gap-2 _border-2 _h-80 _overflow-y-auto"
      >
        <%= for {preview, image, _meta} <- @images do %>
          <img class="myImg" id={"image-#{random_id()}"} src={preview} alt="Muhahahha" onclick={"open_mkh_image('#{image}')"}/>

        <% end %>
      </div>
      <div id="infinite-scroll-marker" phx-hook="InfiniteScroll" data-page={@page}></div>
    </div>
    """
  end
end
