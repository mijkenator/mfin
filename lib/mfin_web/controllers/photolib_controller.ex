defmodule MfinWeb.PhotolibController do
  use MfinWeb, :controller

  def view(conn, params) do

    IO.puts("Photolib params: #{inspect(params)}")

    conn
#    |> assign(:post, post)
    |> render(:view, layout: false)
  end

end
