defmodule Backsol.Repo.Migrations.CreateLicense do
  use Ecto.Migration

  def change do
    create table(:license) do
      add :type, :string
      add :status, :string
      add :key, :string, size: 10000
      add :offlineKey, :string, size: 10000
      add :expirationDate, :string
      add :tagCount, :integer
      add :category, :integer
      add :company, :string
      add :site, :string
      add :address, :string
      add :managerName, :string
      add :managerMobile, :string
      add :comment, :string
      add :created, :string
      timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
    end
  end
end
