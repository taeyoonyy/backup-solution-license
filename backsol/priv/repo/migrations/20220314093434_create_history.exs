defmodule Backsol.Repo.Migrations.CreateHistory do
  use Ecto.Migration

  def change do
    create table(:history) do
      add :company, :string
      add :site, :string
      add :licenseId, :integer
      add :source, :string
      add :action, :string
      add :result, :string
      add :comment, :string
      timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
    end
  end
end
