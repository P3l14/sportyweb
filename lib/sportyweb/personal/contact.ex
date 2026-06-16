defmodule Sportyweb.Personal.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactEmail
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.ContactGroupContact
  alias Sportyweb.Personal.ContactFinancialData
  alias Sportyweb.Personal.ContactNote
  alias Sportyweb.Personal.ContactPhone
  alias Sportyweb.Personal.ContactPostalAddress
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Personal.ContactRoleRelation
  alias Sportyweb.Personal.Qualification
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    belongs_to :club, Club

    has_many :debit_holder, FinancialData,
      foreign_key: :direct_debit_different_account_holder_contact_id,
      references: :id

    has_many :invoice_contact, FinancialData,
      foreign_key: :invoice_different_recipient_contact_id,
      references: :id

    has_many :contracts, Contract
    has_many :contact_roles, ContactRole, on_replace: :delete
    has_many :contact_role_relations, ContactRoleRelation
    has_many :qualifications, Qualification, on_replace: :delete
    many_to_many :contact_groups, ContactGroup, join_through: ContactGroupContact
    many_to_many :emails, Email, join_through: ContactEmail, on_replace: :delete

    many_to_many :financial_data, FinancialData,
      join_through: ContactFinancialData,
      on_replace: :delete

    many_to_many :notes, Note, join_through: ContactNote, on_replace: :delete
    many_to_many :phones, Phone, join_through: ContactPhone, on_replace: :delete

    many_to_many :postal_addresses, PostalAddress,
      join_through: ContactPostalAddress,
      on_replace: :delete

    field :type, :string, default: "person"
    field :name, :string, default: ""
    field :identification_number, :integer
    field :organization_name, :string, default: ""
    field :organization_type, :string, default: ""
    field :person_last_name, :string, default: ""
    field :person_first_name, :string, default: ""
    field :person_middle_names, :string, default: ""
    field :person_birth_name, :string, default: ""
    field :person_gender, :string, default: ""
    field :person_birthday, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Organisation", value: "organization"],
      [key: "Person", value: "person"]
    ]
  end

  def get_valid_organization_types do
    [
      [key: "Behörde", value: "governmental_agency"],
      [key: "Gemeinnützige Organisation", value: "non_profit_organization"],
      [key: "Gemeinnütziges Unternehmen", value: "social_enterprise"],
      [key: "Stiftung", value: "charity"],
      [key: "Unternehmen", value: "corporation"],
      [key: "Verein", value: "club"],
      [key: "Vereinigung", value: "association"],
      [key: "Andere", value: "other"]
    ]
  end

  def get_valid_genders do
    [
      [key: "Männlich", value: "male"],
      [key: "Weiblich", value: "female"],
      [key: "Divers", value: "other"],
      [key: "Keine Angabe", value: "no_info"]
    ]
  end

  def is_organization?(%Contact{} = contact) do
    contact.type == "organization"
  end

  def is_person?(%Contact{} = contact) do
    contact.type == "person"
  end

  def age_in_years(%Contact{} = contact) do
    birthday = contact.person_birthday
    age_in_years(birthday)
  end

  def age_in_years(%Date{} = birthday) do
    # Based on: https://stackoverflow.com/a/71043385
    today = Date.utc_today()

    years_diff = today.year - birthday.year

    # If today's date in the year is before the contact's birthday, substract 1
    if Date.compare(today, %Date{birthday | year: today.year}) == :lt do
      years_diff - 1
    else
      years_diff
    end
  end

  def age_in_years(nil) do
    nil
  end

  def underage_person?(%Contact{} = contact) do
    age_in_years(contact.person_birthday) < 18
  end

  def underage_person?(%Date{} = birthday) do
    age_in_years(birthday) < 18
  end

  def underage_person?("") do
    false
  end

  def underage_person?(nil) do
    false
  end

  def has_active_membership_contract?(%Contact{} = contact) do
    Enum.any?(contact.contracts, fn contract ->
      Contract.is_in_use?(contract, Date.utc_today())
    end)
  end

  def get_departments(%Contact{} = contact) do
    contact.contracts
    |> Enum.filter(fn contract -> Contract.is_in_use?(contract) end)
    |> Enum.flat_map(fn contract -> contract.departments end)
  end

  def get_groups(%Contact{} = contact) do
    contact.contracts
    |> Enum.filter(fn contract -> Contract.is_in_use?(contract) end)
    |> Enum.flat_map(fn contract -> contract.groups end)
  end

  @doc false
  def changeset(contact, attrs, opts \\ []) do
    requires_contact_roles = Keyword.get(opts, :requires_contact_roles, false)
    requires_postal_addresses = Keyword.get(opts, :requires_postal_addresses, true)
    requires_financial_data = Keyword.get(opts, :requires_financial_data, true)
    validate_required_type_condition = Keyword.get(opts, :validate_required_type_condition, :full)

    contact
    |> cast(
      attrs,
      [
        :club_id,
        :type,
        :identification_number,
        :organization_name,
        :organization_type,
        :person_last_name,
        :person_first_name,
        :person_middle_names,
        :person_birth_name,
        :person_gender,
        :person_birthday
      ],
      empty_values: ["", nil]
    )
    |> validate_required([:type])
    |> cast_assoc(:debit_holder, required: false)
    |> cast_assoc(:contact_groups, required: false)
    |> cast_assoc(:contact_roles,
      required: requires_contact_roles,
      sort_param: ContactRole.get_changeset_sort_param(),
      drop_param: ContactRole.get_changeset_drop_param()
    )
    |> cast_assoc(:contact_role_relations,
      required: false
    )
    |> cast_assoc(:postal_addresses,
      required: requires_postal_addresses,
      sort_param: PostalAddress.get_changeset_sort_param(),
      drop_param: PostalAddress.get_changeset_drop_param()
    )
    |> cast_assoc(:emails,
      required: false,
      sort_param: Email.get_changeset_sort_param(),
      drop_param: Email.get_changeset_drop_param()
    )
    |> cast_assoc(:phones,
      required: false,
      sort_param: Phone.get_changeset_sort_param(),
      drop_param: Phone.get_changeset_drop_param()
    )
    |> cast_assoc(:financial_data,
      required: requires_financial_data,
      sort_param: FinancialData.get_changeset_sort_param(),
      drop_param: FinancialData.get_changeset_drop_param()
    )
    |> cast_assoc(:notes,
      required: false,
      sort_param: Note.get_changeset_sort_param(),
      drop_param: Note.get_changeset_drop_param()
    )
    |> update_change(:organization_name, &String.trim/1)
    |> update_change(:person_last_name, &String.trim/1)
    |> update_change(:person_first_name, &String.trim/1)
    |> update_change(:person_middle_names, &String.trim/1)
    |> update_change(:person_birth_name, &String.trim/1)
    |> validate_length(:organization_name, max: 250)
    |> validate_length(:person_last_name, max: 100)
    |> validate_length(:person_first_name, max: 75)
    |> validate_length(:person_middle_names, max: 100)
    |> validate_length(:person_birth_name, max: 75)
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_inclusion(
      :organization_type,
      get_valid_organization_types()
      |> Enum.map(fn organization_type -> organization_type[:value] end)
    )
    |> validate_inclusion(
      :person_gender,
      get_valid_genders() |> Enum.map(fn gender -> gender[:value] end)
    )
    |> validate_date_not_in_future(:person_birthday)
    |> validate_required_type_condition(validate_required_type_condition)
    |> set_name()
    |> ensure_identification_number_is_set()
  end

  def contact_for_membership_changeset(contact, attrs) do
    changeset(contact, attrs)
  end

  @doc false
  def changeset_short_contact(contact, attrs) do
    changeset(contact, attrs,
      requires_contact_roles: true,
      requires_postal_addresses: false,
      requires_financial_data: false,
      validate_required_type_condition: :short
    )
  end

  # generates contact_identification_number for nested contacts like debit_account_holder and different_invoice_contact
  defp ensure_identification_number_is_set(changeset) do
    prepare_changes(changeset, fn change ->
      if get_field(change, :identification_number) do
        change
      else
        club_id = get_field(change, :club_id)

        contact_identification_number =
          Sportyweb.Personal.ContactIdentificationNumber.generate_new(club_id)

        put_change(change, :identification_number, contact_identification_number)
      end
    end)
  end

  defp validate_required_type_condition(changeset, type_option)

  defp validate_required_type_condition(%Ecto.Changeset{} = changeset, :full) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "organization" ->
        changeset |> validate_required([:organization_name, :organization_type])

      "person" ->
        changeset
        |> validate_required([
          :person_last_name,
          :person_first_name,
          :person_gender,
          :person_birthday
        ])

      _ ->
        changeset
    end
  end

  defp validate_required_type_condition(%Ecto.Changeset{} = changeset, :short) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "organization" ->
        changeset |> validate_required([:organization_name, :organization_type])

      "person" ->
        changeset
        |> validate_required([
          :person_last_name,
          :person_first_name
        ])

      _ ->
        changeset
    end
  end

  defp set_name(%Ecto.Changeset{} = changeset) do
    # The "name" field is only set internally and its content is based on
    # the contact type and the content of (multiple) other fields.

    name =
      case get_field(changeset, :type) do
        "organization" ->
          get_field(changeset, :organization_name)

        "person" ->
          person_last_name = get_field(changeset, :person_last_name)
          person_first_name = get_field(changeset, :person_first_name)
          person_middle_names = get_field(changeset, :person_middle_names)
          "#{person_last_name}, #{person_first_name} #{person_middle_names}"

        _ ->
          ""
      end

    changeset |> Ecto.Changeset.change(name: String.trim(name))
  end
end
