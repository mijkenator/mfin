defmodule Mfin.Egjob do
  require Logger
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

  def create_changeset(egjob, attrs, _opts \\ []) do
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
  
  def get_all_jobs(params) do
    Logger.debug("GAJ: #{inspect(params)}")
    from(m in Egjob)
    |> sort(params)
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

  def update(id, params) do
    job = get_job_byid(id)
    changeset(job, params)
    |> Repo.update()
  end 
  
  def update_opt(id, params) do
    from(p in Egjob, where: p.id == ^id, select: p)
    |> Repo.update_all(set: [name: params["name"], updated_at: DateTime.utc_now()])
  end 

  defp sort(query,  %{sort_by: sort_by, sort_dir: sort_dir})
    when sort_by in [:id, :symbol, :quantity, :trade_time, :price] and
         sort_dir in [:asc, :desc] do
    order_by(query, {^sort_dir, ^sort_by})
  end
  defp sort(query, _opts), do: query

end

