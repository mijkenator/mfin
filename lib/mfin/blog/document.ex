defmodule Mfin.Blog.Document do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "blog_documents" do
    field :file, Mfin.Blog.DocumentFile.Type
    belongs_to :post, Mfin.Blog.Post
    belongs_to :creator, Mfin.Accounts.User

    timestamps()
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [])
    |> validate_required([:creator_id])
  end

  def file_changeset(document, attrs) do
    document
    |> cast_attachments(attrs, [:file])
    |> validate_required([:file])
  end
end
