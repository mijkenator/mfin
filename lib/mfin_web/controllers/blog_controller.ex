defmodule MfinWeb.BlogController do
  use MfinWeb, :controller

  def view(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :view, layout: false)
  end
end

