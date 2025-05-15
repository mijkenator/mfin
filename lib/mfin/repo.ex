defmodule Mfin.Repo do
  use Ecto.Repo,
    otp_app: :mfin,
    adapter: Ecto.Adapters.Postgres
end
