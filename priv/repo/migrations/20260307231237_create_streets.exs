defmodule Sportyweb.Repo.Migrations.CreateStreets do
  use Ecto.Migration

  def change do
    create table(:streets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :zipcode, :string
      add :city, :string
      add :street, :string
      add :country, :string

      timestamps(type: :utc_datetime)
    end

    create index(:streets, [:zipcode])
    create index(:streets, [:country])
  end
end
