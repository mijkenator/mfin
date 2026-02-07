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

    file_path = "./uploads/blog_documents/" <> at_id <> "/" <> file_name
    {:ok, {_, content_type}} = FileType.from_path(file_path)
    
    IO.puts("CT: #{inspect(content_type)} Attached: #{inspect(att)}")

    conn
    |> put_resp_header("content-type", content_type)
    |> Plug.Conn.send_file(200, file_path)
  end
  
  def attachment_preview(conn, %{"post_id" => post_id, "attachment_id" => at_id, "file_name" => file_name}) do

    IO.puts("POSTID: #{inspect(post_id)} -> #{inspect(at_id)} -> #{inspect(file_name)}")
    post = Mfin.Blog.get_post!(post_id)

    att = for n <- post.documents, n.id == String.to_integer(at_id), n.file.file_name == file_name, do: n

    basename = Path.basename(file_name)
    rootname = Path.rootname(basename)
    extension = Path.extname(basename)
    preview_file_name = rootname <> "_p_200" <> preview_ext(extension)
    file_path = "./uploads/blog_documents/" <> at_id <> "/preview/" <> preview_file_name
    IO.puts("PREVIEW: #{inspect(file_path)}")
    {:ok, {_, content_type}} = FileType.from_path(file_path)
    
    IO.puts("CT: #{inspect(content_type)} Attached: #{inspect(att)}")

    conn
    |> put_resp_header("content-type", content_type)
    |> Plug.Conn.send_file(200, file_path)
  end
  
  defp preview_ext(".HEIC"), do: ".jpg"
  defp preview_ext(".heic"), do: ".jpg"
  defp preview_ext(ext), do: String.downcase(ext)

end

