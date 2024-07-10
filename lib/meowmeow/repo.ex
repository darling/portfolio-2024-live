defmodule Meowmeow.Repo do
  use Ecto.Repo,
    otp_app: :meowmeow,
    adapter: Ecto.Adapters.Postgres
end
