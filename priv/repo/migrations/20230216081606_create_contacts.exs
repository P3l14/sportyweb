defmodule Sportyweb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :identification_number, :integer, null: false
      add :type, :string, null: false
      add :name, :string, null: false
      add :organization_name, :string, null: false
      add :organization_type, :string, null: false
      add :person_last_name, :string, null: false
      add :person_first_name, :string, null: false
      add :person_middle_names, :string, null: false
      add :person_birth_name, :string, null: false
      add :person_gender, :string, null: false
      add :person_birthday, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:club_id])
    create index(:contacts, [:identification_number, :club_id])

    create table(:contact_identification_numbers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :identification_number, :integer, null: false, default: 1_000_000

      timestamps(type: :utc_datetime)
    end

    create unique_index(:contact_identification_numbers, [:club_id])
  end
end
