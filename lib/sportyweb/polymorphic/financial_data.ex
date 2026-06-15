defmodule Sportyweb.Polymorphic.FinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Directory

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "financial_data" do
    belongs_to :direct_debit_different_account_holder_contact, Contact,
      foreign_key: :direct_debit_different_account_holder_contact_id,
      references: :id

    field :type, :string, default: "direct_debit"
    field :direct_debit_iban, :string, default: ""
    field :direct_debit_institute, :string, default: "", virtual: true
    field :direct_debit_bic, :string, default: "", virtual: true

    belongs_to :invoice_different_recipient_contact, Contact,
      foreign_key: :invoice_different_recipient_contact_id,
      references: :id

    field :invoice_additional_information, :string, default: ""
    field :is_main, :boolean, default: false
    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Lastschrift (IBAN)", value: "direct_debit"],
      [key: "Rechnung", value: "invoice"]
    ]
  end

  def get_changeset_sort_param do
    :financial_data_sort
  end

  def get_changeset_drop_param do
    :financial_data_emails_drop
  end

  @doc false
  def changeset(financial_data, attrs) do
    financial_data
    |> cast(
      attrs,
      [
        :type,
        :direct_debit_iban,
        :direct_debit_different_account_holder_contact_id,
        :invoice_different_recipient_contact_id,
        :invoice_additional_information,
        :is_main
      ],
      empty_values: ["", nil]
    )
    |> validate_required([:type])
    |> cast_assoc(:direct_debit_different_account_holder_contact,
      required: false,
      with: &Contact.changeset_short_contact/2
    )
    # change id placeholder for new contact to nil. Contact is then saved in direct_debit_different_account_holder_contact
    |> update_change(:direct_debit_different_account_holder_contact_id, fn id ->
      if id == new_direct_debit_different_account_holder_value() do
        nil
      else
        id
      end
    end)
    |> cast_assoc(:invoice_different_recipient_contact,
      required: false,
      with: &Contact.changeset_short_contact/2
    )
    # change id placeholder for new contact to nil. Contact is then saved in invoice_different_recipient_contact
    |> update_change(:invoice_different_recipient_contact_id, fn id ->
      if id == new_invoice_different_recipient_value() do
        nil
      else
        id
      end
    end)
    |> update_change(:direct_debit_iban, &String.trim/1)
    |> validate_iban()
    |> update_change(:invoice_additional_information, &String.trim/1)
    |> validate_length(:invoice_additional_information, max: 250)
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_required_type_condition()
  end

  defp validate_iban(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_change(:direct_debit_iban, fn :direct_debit_iban, iban ->
      case Directory.check_iban(iban) do
        {:invalid, message} -> [direct_debit_iban: message]
        _ -> []
      end
    end)
  end

  @doc """
  Value that indicates that a new direct_debit_different_account_holder is used in the form.

  """
  def new_direct_debit_different_account_holder_value() do
    "new"
  end

  @doc """
  Value that indicates that a new direct_invoice_different_recipient is used in the form.

  """
  def new_invoice_different_recipient_value() do
    "new"
  end

  defp validate_required_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "direct_debit" ->
        changeset
        |> validate_required([
          :direct_debit_iban
        ])

      "invoice" ->
        # type information is sufficient. Invoice_different_recipient is optional.
        changeset

      _ ->
        changeset
    end
  end
end
