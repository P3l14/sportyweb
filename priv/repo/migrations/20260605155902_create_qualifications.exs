defmodule Sportyweb.Repo.Migrations.CreateQualifications do
  use Ecto.Migration

  def change do
    create table(:qualifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :dosb_license_type, :string, null: false
      add :dosb_license_level, :string, null: false
      add :dosb_license_number, :string, null: false
      add :dosb_license_number_sports_association, :string, null: false
      add :dosb_license_coach_sport, :string, null: false
      add :dosb_license_sport_instructor_type, :string, null: false
      add :dosb_first_issuance, :date, null: true
      add :dosb_valid_until, :date, null: true
      add :common_type, :string, null: false
      add :common_description, :string, null: false
      add :common_issuance, :date, null: true
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:qualifications, [:contact_id])
  end
end
