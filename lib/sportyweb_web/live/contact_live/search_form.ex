defmodule SportywebWeb.ContactLive.Search.SearchForm do
  @moduledoc """
  Data description and validation for the user input of `SportywebWeb.ContactLive.Search` LiveView.

  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactIdentificationNumber

  @primary_key false
  embedded_schema do
    field :type, :string
    field :contact_identification_number, :integer
    field :search_scope, :string
    field :include_invalid, :boolean
    embeds_one :contact, Contact
  end

  def get_valid_types do
    [
      [key: "Suche mit Kontaktnummer", value: "contact_identification_number"],
      [key: "Suche mit Kontaktdaten", value: "contact"]
    ]
  end

  def get_valid_search_scopes() do
    [
      [key: "alle", value: "all"],
      [key: "ohne Mitglieder", value: "without_members"],
      [key: "nur Mitglieder", value: "only_members"]
    ]
  end

  def changeset(search_form, attrs \\ %{}) do
    search_form
    |> cast(attrs, [:type, :contact_identification_number, :search_scope, :include_invalid],
      empty_values: ["", nil]
    )
    |> validate_required([:type], message: "Bitte wählen Sie eine Suchart aus.")
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_required_type_condition()
  end

  defp validate_required_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "contact_identification_number" ->
        changeset
        |> validate_required([:contact_identification_number])
        |> validate_inclusion(
          :contact_identification_number,
          10_000_000..99_999_999,
          message: "Die Kontaktnummer muss im Wertebereich von 10000000 bis 99999999 liegen."
        )
        |> validate_contact_identification_number()

      "contact" ->
        changeset
        |> validate_required([:search_scope, :include_invalid])
        |> validate_inclusion(
          :search_scope,
          get_valid_search_scopes() |> Enum.map(fn search_scope -> search_scope[:value] end)
        )
        |> cast_embed(:contact, with: &changeset_contact_for_search/2)

      _ ->
        changeset
    end
  end

  defp changeset_contact_for_search(contact, attrs) do
    contact
    |> cast(
      attrs,
      [
        :club_id,
        :type,
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
  end

  defp validate_contact_identification_number(%Ecto.Changeset{} = changeset) do
    contact_identification_number = changeset |> get_field(:contact_identification_number)

    if contact_identification_number &&
         contact_identification_number |> Integer.digits() |> length() == 8 &&
         not ContactIdentificationNumber.valid?(contact_identification_number) do
      changeset
      |> add_error(
        :contact_identification_number,
        "Die Prüfziffer der Kontaktnummer stimmt nicht. Bitte überprüfen Sie Ihre Eingabe."
      )
    else
      changeset
    end
  end
end
