defmodule Sportyweb.Personal.ContactGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroupContact
  alias Sportyweb.Personal.ContactGroup

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_groups" do
    field :type, :string, default: "family"
    field :name, :string, default: ""
    belongs_to :club, Club
    many_to_many :contacts, Contact, join_through: ContactGroupContact, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Famile", value: "family"]
    ]
  end

  def get_changeset_sort_param do
    :contacts_sort
  end

  def get_changeset_drop_param do
    :contacts_drop
  end

  @doc false
  def changeset(contact_group, attrs) do
    contact_group
    |> cast(attrs, [:club_id, :name, :type])
    |> validate_required([:club_id])
  end

  @doc false
  def changeset_for_form(contact_group, attrs) do
    contact_group
    |> cast(attrs, [:club_id, :name, :type])
    |> cast_assoc(:contacts,
      required: false,
      with: &contact_changeset/2,
      sort_param: ContactGroup.get_changeset_sort_param(),
      drop_param: ContactGroup.get_changeset_drop_param()
    )
    |> validate_required([:club_id, :name, :type])
  end

  def contact_changeset(contact, attrs) do
    contact
    |> cast(attrs, [:id, :club_id])
    |> validate_required([:id, :club_id])
  end
end
