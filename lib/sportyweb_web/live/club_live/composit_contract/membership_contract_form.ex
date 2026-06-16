defmodule SportywebWeb.ClubLive.MembershipContractForm do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias SportywebWeb.ClubLive.DepartmentSelection
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
  end
end
