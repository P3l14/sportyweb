defmodule Sportyweb.Repo.Migrations.CreateContactRoles do
  use Ecto.Migration

  def change do
    create table(:contact_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :custom_name, :string, null: true
      add :valid_from, :date, null: false
      add :valid_until, :date, null: true

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contact_roles, [:contact_id])
    create index(:contact_roles, [:name])
  end
end
