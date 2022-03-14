defmodule Backsol.License do
  use Ecto.Schema

  schema "license" do
    field :type, :string
    field :status, :string
    field :key, :string, size: 10000
    field :offlineKey, :string, size: 10000
    field :expirationDate, :string
    field :tagCount, :integer
    field :userCount, :integer
    field :company, :string
    field :site, :string
    field :address, :string
    field :managerName, :string
    field :managerMobile, :string
    field :comment, :string
    timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
  end

  def changeset(license, params \\ %{}) do
    license
    |> Ecto.Changeset.cast(params, [:status, :address, :company, :site, :managerName, :managerMobile, :comment])
  end

end
