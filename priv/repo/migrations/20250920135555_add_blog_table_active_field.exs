defmodule Mfin.Repo.Migrations.AddBlogTableActiveField do
  use Ecto.Migration

  def up do
    alter table(:blog_posts) do 
        add :status, :integer, default: 0 
    end
  end

  def down do 
    alter table(:blog_posts) do 
        remove :status
    end
  end
end
