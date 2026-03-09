defmodule Sportyweb.Repo.Migrations.CreateBanks do
  use Ecto.Migration

  def change do
    create table(:banks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :bankcode, :string
      add :bic, :string
      add :name, :string
      add :shortname, :string
      add :countrycode, :string

      timestamps(type: :utc_datetime)
    end

    create index(:banks, [:countrycode])
    create index(:banks, [:bankcode])
    create index(:banks, [:bic])
  end
end
