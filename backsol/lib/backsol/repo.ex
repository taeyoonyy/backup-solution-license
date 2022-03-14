defmodule Backsol.Repo do
  use Ecto.Repo,
    otp_app: :backsol,
    adapter: Ecto.Adapters.Postgres
end
