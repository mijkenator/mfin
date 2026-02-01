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
  
  def attachment(conn, %{"post_id" => post_id, "attachment_id" => at_id, "file_name" => file_name}) do

    IO.puts("POSTID: #{inspect(post_id)} -> #{inspect(at_id)} -> #{inspect(file_name)}")
    post = Mfin.Blog.get_post!(post_id)

    att = for n <- post.documents, n.id == String.to_integer(at_id), n.file.file_name == file_name, do: n

    IO.puts("Attached: #{inspect(att)}")

    file_path = "./uploads/blog_documents/" <> at_id <> "/" <> file_name
    {:ok, {_, content_type}} = FileType.from_path(file_path)

    conn
    |> put_resp_header("content-type", content_type)
    |> Plug.Conn.send_file(200, file_path)
  end
end

