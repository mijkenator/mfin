defmodule Mfin.Repo.Migrations.AddBlogDocTable do
  use Ecto.Migration

  def up do
    create table("blog_documents") do
      add :creator_id,  :integer
      add :post_id,  :integer
      add :file, :string, size: 256

      timestamps()
    end
  end

  def down do
    drop table("blog_documents")
  end
end
