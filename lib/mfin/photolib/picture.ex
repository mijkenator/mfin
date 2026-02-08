defmodule Mfin.Photolib.Picture do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  
  alias Mfin.Repo
  alias Mfin.Photolib.Picture

  schema "photolib" do
    field :picture, :string
    field :status, :string
    field :active, :boolean
    field :meta, :map
    field :dhash, :binary
    field :exif_date, :naive_datetime

    timestamps()
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:picture, :status, :active, :meta, :dhash, :exif_date])
    |> validate_required([:picture])
  end

  def insert_picture(attrs) do
    Logger.info("Insert Picture: #{inspect(attrs)}")
    %Picture{}
    |> changeset(attrs)
    |> Repo.insert()
  end

end

