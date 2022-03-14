defmodule Backsol.Account do
  use Ecto.Schema

  schema "account" do
    field :user, :string
    field :password, :string
    field :authority, :string
    field :name, :string
    field :mobile, :string
    timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
  end

  def changeset(account, params \\ %{}) do
    account
    |> Ecto.Changeset.cast(params, [:password, :name, :mobile])
  end

end
