defmodule Mfin.Egjob do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias Mfin.Repo
  alias Mfin.Egjob

  schema "egjobs" do
    field :name, :string
    field :status, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(egjob, params \\ :empty) do
    egjob
    |> cast(params, [:name, :status])
  end

  def create_changeset(egjob, attrs, opts \\ []) do
    egjob
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 40)
  end
  
  def create_job(attrs) do
    %Egjob{}
    |> create_changeset(attrs)
    |> Repo.insert()
  end

  def delete_job_byid(id) do
    %Egjob{id: id} 
    |> Repo.delete
  end

  def get_all_jobs() do
    #Repo.all(Egjob) 
    from(m in Egjob)
    |> order_by({:asc, :id})
    |> Repo.all()
  end

  def get_job_byid(id) do
    Ecto.Query.from(j in Egjob, where: j.id == ^id)
    |> Repo.one()
  end

  def toggle_job(id) do
    job = get_job_byid(id)
    changeset(job, %{status: toggle_status(job.status)})
    |> Repo.update()
  end

  defp toggle_status(0), do: 1
  defp toggle_status(_), do: 0

end

