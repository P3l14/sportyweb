defmodule Sportyweb.Personal.ContactRole do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRoleRelation

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_roles" do
    belongs_to :contact, Contact
    field :name, :string, default: nil
    field :valid_from, :date, default: nil
    field :valid_until, :date, default: nil
    has_many :contact_role_relations, ContactRoleRelation, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def get_valid_names do
    [
      [key: "Erziehungsberechtigter", value: "legal guardian"],
      [key: "Interessent", value: "interested"],
      [key: "Kursteilnehmer", value: "participants"],
      [key: "Lieferant", value: "supplier"],
      [key: "Spender", value: "donor"],
      [key: "Sponsor", value: "sponsor"],
      [key: "Veranstaltungsbesucher", value: "visitor"]
    ]
  end

  def get_changeset_sort_param do
    :contact_roles_sort
  end

  def get_changeset_drop_param do
    :contact_roles_drop
  end

  @doc false
  def changeset(contact_role, attrs) do
    contact_role
    |> cast(attrs, [:valid_from, :valid_until, :name, :contact_id])
    |> validate_required([:valid_from, :name])
    |> validate_inclusion(
      :name,
      get_valid_names() |> Enum.map(fn name -> name[:value] end)
    )
    |> validate_dates_order(
      :valid_from,
      :valid_until,
      "Muss zeitlich später als \"Gültig seit\" sein!"
    )
    |> cast_assoc(:contact_role_relations,
      required: false,
      sort_param: ContactRoleRelation.get_changeset_sort_param(),
      drop_param: ContactRoleRelation.get_changeset_drop_param()
    )
  end
end
