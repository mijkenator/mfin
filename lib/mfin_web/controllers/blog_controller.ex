defmodule MfinWeb.BlogController do
  use MfinWeb, :controller

  def view(conn, %{"post_id" => post_id}) do

    IO.puts("POSTID: #{inspect(post_id)}")
    post = Mfin.Blog.get_post!(post_id)
    IO.puts("POST: #{inspect(post)}")

    conn
    |> assign(:post, post)
    |> render(:view, layout: false)
  end
end

