defmodule Sportyweb.Personal.ContactRoleRelation do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Personal.ContactRoleRelation
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_role_relations" do
    belongs_to :contact_role, ContactRole
    belongs_to :contact, Contact
    belongs_to :department, Department
    belongs_to :group, Group
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

  def get_target(%ContactRoleRelation{} = contact_role_relation) do
    cond do
      contact_role_relation.contact_id ->
        contact_role_relation.contact

      contact_role_relation.department_id ->
        contact_role_relation.department

      contact_role_relation.group_id ->
        contact_role_relation.group

      true ->
        nil
    end
  end

  @doc false
  def changeset(contact_role_relation, attrs) do
    contact_role_relation
    |> cast(attrs, [
      :contact_role_id,
      :contact_id,
      :department_id,
      :group_id,
      :valid_from,
      :valid_until
    ])
    |> validate_required([:valid_from])
    |> validate_at_least_one_relation_present
    |> validate_dates_order(
      :valid_from,
      :valid_until,
      "Muss zeitlich später als \"Gültig seit\" sein!"
    )
  end

  defp validate_at_least_one_relation_present(changeset) do
    if [
         get_field(changeset, :contact_id),
         get_field(changeset, :department_id),
         get_field(changeset, :group_id)
       ]
       |> Enum.any?() do
      changeset
    else
      changeset |> add_error(:valid_from, "Es muss eine Beziehung angegeben werden!")
    end
  end
end
