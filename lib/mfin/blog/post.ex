defmodule Mfin.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blog_posts" do
    field :title, :string
    field :content, :string
    field :status, :integer

    has_many :documents, Mfin.Blog.Document,
      on_replace: :delete,
      foreign_key: :post_id,
      preload_order: [desc: :inserted_at]

    belongs_to :author, Mfin.Accounts.User

    timestamps()
  end

  def changeset(post, attrs, documents \\ nil) do
    post
    |> cast(attrs, [:title, :content])
    |> validate_required([:title, :content])
    |> maybe_put_documents(documents)
  end

  defp maybe_put_documents(changeset, nil), do: changeset
  defp maybe_put_documents(changeset, documents) when is_list(documents) do
    put_assoc(changeset, :documents, documents)
  end
end
