defmodule Sportyweb.Repo.Migrations.CreateContactRoleRelations do
  use Ecto.Migration

  def change do
    create table(:contact_role_relations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :valid_from, :date, null: false
      add :valid_until, :date, null: true

      add :contact_role_id, references(:contact_roles, on_delete: :delete_all, type: :binary_id),
        null: true

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: true

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: true

      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:contact_role_relations, [:contact_role_id])
    create index(:contact_role_relations, [:contact_id])
    create index(:contact_role_relations, [:department_id])
    create index(:contact_role_relations, [:group_id])
  end
end
