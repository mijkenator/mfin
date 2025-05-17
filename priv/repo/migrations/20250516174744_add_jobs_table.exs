defmodule Mfin.Repo.Migrations.AddJobsTable do
  use Ecto.Migration


  def up do
    create table("egjobs") do
      add :name,    :string, size: 40
      add :status,  :integer

      timestamps()
    end
  end

  def down do
    drop table("egjobs")
  end

end
