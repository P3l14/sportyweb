defmodule Sportyweb.Repo.Migrations.CreateFinancialData do
  use Ecto.Migration

  def change do
    create table(:financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :direct_debit_iban, :string, null: false
      add :invoice_additional_information, :text, null: false
      add :is_main, :boolean, null: false

      add :direct_debit_different_account_holder_contact_id,
          references(:contacts, on_delete: :nilify_all, type: :binary_id),
          null: true

      add :invoice_different_recipient_contact_id,
          references(:contacts, on_delete: :nilify_all, type: :binary_id),
          null: true

      timestamps(type: :utc_datetime)
    end

    create index(:financial_data, [:direct_debit_different_account_holder_contact_id])
    create index(:financial_data, [:invoice_different_recipient_contact_id])
  end
end
