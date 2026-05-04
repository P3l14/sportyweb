defmodule Sportyweb.Personal.ContactRoleRelation do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_role_relations" do
    belongs_to :contact_role, ContactRole
    belongs_to :contact, Contact
    field :valid_from, :date, default: nil
    field :valid_until, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_changeset_sort_param do
    :contact_role_relations_sort
  end

  def get_changeset_drop_param do
    :contact_role_relations_drop
  end

  @doc false
  def changeset(contact_role_relation, attrs) do
    contact_role_relation
    |> cast(attrs, [:contact_role_id, :contact_id, :valid_from, :valid_until])
    |> validate_required([:valid_from, :contact_id])
    |> validate_dates_order(
      :valid_from,
      :valid_until,
      "Muss zeitlich später als \"Gültig seit\" sein!"
    )
  end
end
