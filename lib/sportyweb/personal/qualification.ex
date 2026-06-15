defmodule Sportyweb.Personal.Qualification do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias Sportyweb.Personal.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "qualifications" do
    field :type, :string, default: ""
    field :dosb_license_type, :string, default: ""
    field :dosb_license_level, :string, default: ""
    field :dosb_license_number, :string, default: ""
    field :dosb_license_number_sports_association, :string, default: ""
    field :dosb_license_coach_sport, :string, default: ""
    field :dosb_license_sport_instructor_type, :string, default: ""
    field :dosb_first_issuance, :date, default: nil
    field :dosb_valid_until, :date, default: nil
    field :common_type, :string, default: ""
    field :common_description, :string, default: ""
    field :common_issuance, :date, default: nil
    belongs_to :contact, Contact

    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Allgemeine Qualifikation", value: "common"],
      [key: "DOSB Lizenz", value: "dosb license"]
    ]
  end

  def get_valid_dosb_license_types do
    [
      [key: "Übungsleiter", value: "sport instructor"],
      [key: "Trainer für Breitensport", value: "coach common"],
      [key: "Trainer für Leistungssport", value: "coach professional"],
      [key: "Jugendleiter", value: "youth leader"],
      [key: "Vereinsmanager", value: "club manager"]
    ]
  end

  def get_valid_dosb_license_levels(dosb_license_type)

  def get_valid_dosb_license_levels("youth leader") do
    [
      [key: "C", value: "C"]
    ]
  end

  def get_valid_dosb_license_levels(dosb_license_type)
      when dosb_license_type in ["sport instructor", "club manager"] do
    [
      [key: "C", value: "C"],
      [key: "B", value: "B"]
    ]
  end

  def get_valid_dosb_license_levels("coach common") do
    [
      [key: "C", value: "C"],
      [key: "B", value: "B"],
      [key: "A", value: "A"]
    ]
  end

  def get_valid_dosb_license_levels("coach professional") do
    [
      [key: "C", value: "C"],
      [key: "B", value: "B"],
      [key: "A", value: "A"],
      [key: "Diplom Trainer", value: "diploma coach"]
    ]
  end

  def get_valid_dosb_license_levels(_) do
    []
  end

  def get_valid_dosb_license_levels do
    [
      [key: "C", value: "C"],
      [key: "B", value: "B"],
      [key: "A", value: "A"],
      [key: "Diplom Trainer", value: "diploma coach"]
    ]
  end

  def get_valid_dosb_license_sport_instructor_types do
    [
      [key: "Breitensport", value: "popular sports"],
      [key: "Prävention", value: "prevention"],
      [key: "Rehabilitation", value: "rehabilitation"]
    ]
  end

  def get_valid_common_types do
    [
      [key: "Erste Hilfekurs", value: "first aid"],
      [key: "Ausbildung", value: "apprenticeship"],
      [key: "Akademischer Abschluss", value: "academic"],
      [key: "sonstige", value: "misc"]
    ]
  end

  @doc """
  Checks if the input of the dosb_license_coach_sport is required for the passed dosb_license_type.


  """
  def requires_dosb_license_coach_sport?(dosb_license_type)

  def requires_dosb_license_coach_sport?(dosb_license_type)
      when dosb_license_type in ["coach common", "coach professional"] do
    true
  end

  def requires_dosb_license_coach_sport?(_) do
    false
  end

  @doc """
  Checks if the input of the dosb_license_sport_instructor_type is required for the passed dosb_license_type and dosb_license_level.


  """
  def requires_dosb_license_sport_instructor_type?(dosb_license_type, dosb_license_level)

  def requires_dosb_license_sport_instructor_type?("sport instructor", "B") do
    true
  end

  def requires_dosb_license_sport_instructor_type?(_, _) do
    false
  end

  @doc false
  def changeset(qualification, attrs) do
    qualification
    |> cast(
      attrs,
      [
        :type,
        :dosb_license_type,
        :dosb_license_level,
        :dosb_license_number,
        :dosb_license_number_sports_association,
        :dosb_license_coach_sport,
        :dosb_license_sport_instructor_type,
        :dosb_first_issuance,
        :dosb_valid_until,
        :common_type,
        :common_description,
        :common_issuance,
        :contact_id
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :type,
      :contact_id
    ])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_type_conditions()
  end

  defp validate_type_conditions(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "common" ->
        changeset =
          changeset
          |> validate_required([:common_type, :common_issuance])
          |> validate_inclusion(
            :common_type,
            get_valid_common_types() |> Enum.map(fn type -> type[:value] end)
          )
          |> validate_date_not_in_future(:common_issuance)

        if get_field(changeset, :common_type) == "first aid" do
          changeset
        else
          changeset
          |> validate_required([:common_description])
          |> update_change(:common_description, &String.trim/1)
          |> validate_length(:common_description, max: 250)
        end

      "dosb license" ->
        changeset =
          changeset
          |> validate_required([
            :dosb_license_type,
            :dosb_license_level,
            :dosb_license_number,
            :dosb_first_issuance,
            :dosb_valid_until
          ])
          |> validate_inclusion(
            :dosb_license_type,
            get_valid_dosb_license_types() |> Enum.map(fn type -> type[:value] end)
          )
          |> validate_inclusion(
            :dosb_license_level,
            Enum.map(
              get_valid_dosb_license_levels(get_field(changeset, :dosb_license_type)),
              fn type -> type[:value] end
            )
          )
          |> validate_inclusion(
            :dosb_license_sport_instructor_type,
            get_valid_dosb_license_sport_instructor_types()
            |> Enum.map(fn type -> type[:value] end)
          )
          |> validate_date_not_in_future(:dosb_first_issuance)
          |> validate_dates_order(
            :dosb_first_issuance,
            :dosb_valid_until,
            "Muss zeitlich später als oder gleich \"Erstaustellungsdatum\" sein!"
          )

        changeset =
          if requires_dosb_license_coach_sport?(get_field(changeset, :dosb_license_type)) do
            changeset
            |> validate_required([:dosb_license_coach_sport])
            |> update_change(:dosb_license_coach_sport, &String.trim/1)
            |> validate_length(:dosb_license_coach_sport, max: 100)
          else
            changeset
          end

        if requires_dosb_license_sport_instructor_type?(
             get_field(changeset, :dosb_license_type),
             get_field(changeset, :dosb_license_level)
           ) do
          changeset
          |> validate_required([:dosb_license_sport_instructor_type])
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
