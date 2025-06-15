defmodule MfinWeb.Forms.SortingForm do
  import Ecto.Changeset
  require Logger

  alias Mfin.EctoHelper

  @fields %{
    sort_by: EctoHelper.enum([:id]),
    sort_dir: EctoHelper.enum([:asc, :desc])
  }

  @default_values %{
    sort_by: :id,
    sort_dir: :asc
  }

  def parse(params) do
    Logger.debug "EWFSF params: #{inspect(params)}"
    {@default_values, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  def default_values(overrides \\ %{}), do: Map.merge(@default_values, overrides)
end
