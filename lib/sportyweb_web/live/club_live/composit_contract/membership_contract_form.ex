defmodule SportywebWeb.ClubLive.MembershipContractForm do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias SportywebWeb.ClubLive.DepartmentSelection
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @primary_key false
  embedded_schema do
    field :contact_id, :string, default: nil
    field :contact_group_id, :string, default: nil
    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :club_fee_id, :binary_id, default: nil
    embeds_one :contact, Sportyweb.Personal.Contact
    embeds_one :contact_group, Sportyweb.Personal.ContactGroup
    field :legal_guardian_contact_id, :string, default: nil
    embeds_one :legal_guardian_contact, Sportyweb.Personal.Contact
    embeds_many :department_selections, DepartmentSelection, on_replace: :delete
  end

  @doc """
  Value that indicates that a new contact is used in the form recorded

  """
  def new_contact_value() do
    "new"
  end

  def changeset(membership_contract_form, attrs \\ %{}) do
    membership_contract_form
    |> cast(attrs, [
      :contact_id,
      :signing_date,
      :start_date,
      :club_fee_id,
      :legal_guardian_contact_id,
      :contact_group_id
    ])
    |> validate_required([:contact_id, :signing_date, :start_date, :club_fee_id])
    |> validate_dates_order(
      :signing_date,
      :start_date,
      "Muss zeitlich später als oder gleich \"Unterzeichnungsdatum\" sein!"
    )
    |> cast_embed(:contact, with: &Contact.contact_for_membership_changeset/2)
    |> cast_embed(:contact_group)
    |> cast_embed(:legal_guardian_contact, with: &Contact.changeset_short_contact/2)
    |> cast_embed(:department_selections)
    |> validate_used_contact_id()
    |> validate_legal_guardian()
  end

  defp validate_used_contact_id(changeset) do
    contact_id = get_change(changeset, :contact_id)

    if contact_id not in ["new", "", nil] do
      contact = Personal.get_contact!(contact_id, [:postal_addresses, :financial_data])
      contact_changeset = Contact.contact_for_membership_changeset(contact, %{})

      if contact_changeset.valid? do
        changeset
      else
        changeset
        |> add_error(
          :contact_id,
          "Beim ausgewählten Kontakt fehlen noch Informationen wie das Geburtsdatum, das Geschlecht, die Adresse und/oder die Zahlungsinformationen. Diese müssen vor einer Verwendung über 'Kontakt bearbeiten' nach erfasst werden."
        )
      end
    else
      changeset
    end
  end

  defp validate_legal_guardian(changeset) do
    if contact = get_change(changeset, :contact) do
      # only check for empty value. When a new contact is selected then there are rules on its own.
      if get_change(contact, :person_birthday) &&
           Contact.underage_person?(get_change(contact, :person_birthday)) &&
           get_change(changeset, :legal_guardian_contact_id) == nil do
        changeset
        |> add_error(
          :legal_guardian_contact_id,
          "Es muss ein Erziehungsberechtigter ausgewählt werden."
        )
      else
        changeset
      end
    else
      changeset
    end
  end
end
