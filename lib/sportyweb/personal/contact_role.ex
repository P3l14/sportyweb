defmodule Sportyweb.Personal.ContactRole do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Personal.ContactRoleRelation

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_roles" do
    belongs_to :contact, Contact
    field :name, :string, default: nil
    field :custom_name, :string, default: nil
    field :valid_from, :date, default: nil
    field :valid_until, :date, default: nil
    has_many :contact_role_relations, ContactRoleRelation, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def get_valid_names(%Contact{} = contact) do
    is_member =
      if Ecto.assoc_loaded?(contact.contracts) do
        Contact.has_active_membership_contract?(contact)
      else
        false
      end

    get_valid_names(is_member)
  end

  def get_valid_names(true) do
    get_valid_names()
  end

  def get_valid_names(false) do
    get_valid_names() |> Enum.filter(fn entry -> entry[:requires_membership] == nil end)
  end

  def get_valid_names_for_type("organization", false) do
    get_valid_names() |> Enum.filter(fn entry -> entry[:allowed_for_organization] end)
  end

  def get_valid_names_for_type(_, is_member) do
    get_valid_names(is_member)
  end

  def get_valid_names do
    [
      [
        key: "Geschäftsführer des Vereins",
        value: "executive director",
        requires_membership: true
      ],
      [key: "1. Vorstandsvorsitzende", value: "first chairman", requires_membership: true],
      [key: "2. Vorstandsvorsitzende", value: "second chairman", requires_membership: true],
      [
        key: "weitere Vorstandsrolle",
        value: "board role",
        requires_membership: true,
        custom_input: true
      ],
      [key: "Schatzmeister", value: "treasurer", requires_membership: true],
      [
        key: "Abteilungsleiter",
        value: "head of department",
        requires_membership: true,
        has_role_relation: :department
      ],
      [
        key: "Gruppenleiter",
        value: "head of group",
        requires_membership: true,
        has_role_relation: :group
      ],
      [key: "Vereinsmitarbeiter", value: "club staff", custom_input: true],
      [key: "Trainer", value: "coach",  has_role_relation: :department],
      [key: "Übungsleiter", value: "sport instructor",  has_role_relation: :department],
      [key: "Kassenprüfer", value: "cash auditor", requires_membership: true],
      [key: "Schriftführer", value: "secretary", requires_membership: true],
      [key: "Jugendleiter", value: "youth leader", requires_membership: true],
      [key: "Beisitzer Vorstand", value: "assessor", requires_membership: true],
      [key: "Erziehungsberechtigter", value: "legal guardian", has_role_relation: :contact],
      [key: "Interessent", value: "interested"],
      [key: "Kursteilnehmer", value: "participants"],
      [key: "Lieferant", value: "supplier", allowed_for_organization: true],
      [key: "Spender", value: "donor", allowed_for_organization: true],
      [key: "Sponsor", value: "sponsor", allowed_for_organization: true],
      [key: "Veranstaltungsbesucher", value: "visitor"],
      [key: "Bankkontoinhaber", value: "debit account holder", allowed_for_organization: true],
      [key: "Rechnungsempfänger", value: "invoice recipient", allowed_for_organization: true],
      [
        key: "weitere Rolle",
        value: "other role",
        custom_input: true,
        allowed_for_organization: true
      ]
    ]
  end

  def membership_role?(role_name) do
    entry = get_role_relation_entry(role_name)
    entry[:requires_membership]
  end

  def get_role_relation_type(role_name) do
    entry = get_role_relation_entry(role_name)
    entry[:has_role_relation]
  end

  def get_role_relation_entry(role_name) do
    get_valid_names() |> Enum.find(fn entry -> entry[:value] == role_name end)
  end

  def get_changeset_sort_param do
    :contact_roles_sort
  end

  def get_changeset_drop_param do
    :contact_roles_drop
  end

  def is_in_use?(%ContactRole{} = contact_role, %Date{} = date \\ Date.utc_today()) do
    Date.compare(date, contact_role.valid_from) != :lt &&
      (is_nil(contact_role.valid_until) || Date.compare(date, contact_role.valid_until) == :lt)
  end

  def is_archived?(%ContactRole{} = contact_role, %Date{} = date \\ Date.utc_today()) do
    contact_role.valid_until && Date.compare(date, contact_role.valid_until) != :lt
  end

  def has_relations?(role_name) do
    get_role_relation_type(role_name)
  end

  def has_custom_input?(role_name) do
    get_role_relation_entry(role_name)[:custom_input]
  end

  @doc false
  def changeset(contact_role, attrs) do
    contact_role
    |> cast(attrs, [:valid_from, :valid_until, :name, :contact_id, :custom_name])
    |> validate_required([:valid_from, :name], empty_values: ["", nil])
    |> validate_inclusion(
      :name,
      get_valid_names() |> Enum.map(fn name -> name[:value] end)
    )
    |> validate_custom_name()
    |> update_change(:custom_name, &String.trim/1)
    |> validate_length(:custom_name, max: 100)
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

  defp validate_custom_name(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    name = get_field(changeset, :type)
    entry_for_name = get_valid_names() |> Enum.find(fn entry -> entry[:key] == name end)

    if entry_for_name[:custom_input] do
      changeset |> validate_required([:custom_name])
    else
      changeset
    end
  end
end
