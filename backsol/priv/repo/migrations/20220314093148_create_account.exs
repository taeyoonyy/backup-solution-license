defmodule Backsol.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account) do
      add :user, :string
      add :password, :string
      add :authority, :string
      add :name, :string
      add :mobile, :string
      timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
    end
  end
end
