defmodule Mfin.Repo.Migrations.AddBlogTable do
  use Ecto.Migration

  def up do
    create table("blog_posts") do
      add :title,  :string, size: 128
      add :content,  :text
      add :author_id, :integer

      timestamps()
    end
  end

  def down do
    drop table("blog_posts")
  end
end
