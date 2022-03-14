defmodule Backsol.History do
  use Ecto.Schema

  schema "history" do
    field :company, :string
    field :site, :string
    field :licenseId, :integer
    field :source, :string
    field :action, :string
    field :result, :string
    field :comment, :string
    timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
  end

  def changeset(history, params \\ %{}) do
    history
    |> Ecto.Changeset.cast(params, [:comment])
  end

end
