defmodule Mfin.Blog do
  import Ecto.Query
  alias Mfin.Repo
  alias Mfin.Blog.Post
  alias Mfin.Blog.Document
  alias Mfin.Blog.DocumentFile
  require Logger

  # Basic Post CRUD operations
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> preload_associations([:documents])
  end

  def preload_associations(post_or_posts, preloads \\ [:documents]) do
    Repo.preload(post_or_posts, preloads)
  end

  def create_post(attrs, documents, %{id: author_id}) do
    %Post{author_id: author_id}
    |> Post.changeset(attrs, documents)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs, documents \\ nil) do
    post
    |> Post.changeset(attrs, documents)
    |> Repo.update()
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def get_document!(id) do
    Document
    |> where([d], d.id == ^id)
    |> Repo.one!()
  end

  # Document creation function
  def create_unattached_document(attrs \\ %{}, %{id: creator_id}) do
    changeset =
      %Document{creator_id: creator_id}
      |> Document.changeset(attrs)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:document, changeset)
      |> Ecto.Multi.update(
        :document_with_file,
        &Document.file_changeset(&1.document, attrs)
      )
      |> Repo.transaction()

    case result do
      {:ok, %{document_with_file: document}} -> {:ok, document}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end
end
