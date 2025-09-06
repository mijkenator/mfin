defmodule Mfin.Blog.DocumentFile do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]

  def storage_dir(_version, {_file, document}) do
    IO.puts("MBDF: #{inspect(document, limit: :infinity)}")
    "uploads/blog_documents/#{document.id}"
  end
end
