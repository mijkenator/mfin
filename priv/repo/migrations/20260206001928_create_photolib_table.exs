defmodule Mfin.Repo.Migrations.CreatePhotolibTable do
  use Ecto.Migration

  def up do
    create table("photolib") do
      add :picture,  :string, size: 128
      add :status, :string, size: 20
      add :active, :boolean, default: true 
      add :meta,  :map, default: %{}
      add :dhash, :binary
      add :exif_date, :naive_datetime

      timestamps()
    end


    create index(:photolib, [:dhash])
    create index(:photolib, [:exif_date])
    create unique_index(:photolib, [:picture, :dhash])

  end

  def down do
    drop table("photolib")
  end
end
