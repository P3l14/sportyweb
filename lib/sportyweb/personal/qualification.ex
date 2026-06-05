defmodule Sportyweb.Personal.Qualification do
  use Ecto.Schema
  import Ecto.Changeset
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

  @doc false
  def changeset(qualification, attrs) do
    qualification
    |> cast(attrs, [
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
      :common_issuance
    ])
    |> validate_required([
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
      :common_issuance
    ])
  end
end
