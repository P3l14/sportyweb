defmodule SportywebWeb.ClubLive.MembershipContractForm do
  use Ecto.Schema
  import Ecto.Changeset
  alias SportywebWeb.ClubLive.DepartmentSelection
  alias Sportyweb.Personal.Contact

  @primary_key false
  embedded_schema do
    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :club_fee_id, :binary_id, default: nil
    embeds_one :contact, Sportyweb.Personal.Contact
    embeds_many :department_selections, DepartmentSelection, on_replace: :delete
  end

  def changeset(membership_contract_form, attrs \\ %{}) do
    membership_contract_form
    |> cast(attrs, [
      :signing_date,
      :start_date,
      :club_fee_id
    ])
    |> validate_required([:signing_date, :start_date, :club_fee_id])
    |> cast_embed(:contact, with: &Contact.contact_for_membership_changeset/2)
    |> cast_embed(:department_selections)
  end
end
