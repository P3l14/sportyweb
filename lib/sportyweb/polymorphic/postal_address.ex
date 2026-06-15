defmodule Sportyweb.Polymorphic.PostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "postal_addresses" do
    field :type, :string, default: "residence"
    field :street, :string, default: ""
    field :street_number, :string, default: ""
    field :street_additional_information, :string, default: ""
    field :zipcode, :string, default: ""
    field :city, :string, default: ""
    field :country, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def get_valid_countries do
    [
      [key: "Deutschland", value: "DEU"],
      [key: "Österreich", value: "AUT"],
      [key: "Schweiz", value: "CHE"]
    ]
  end

  def get_valid_types do
    [
      [key: "Wohnsitz", value: "residence"],
      [key: "Betriebsadresse", value: "company adress"],
      [key: "abweichende Rechnungsadresse", value: "billing"],
      [key: "Firmensitz", value: "company headquarters"],
      [key: "abweichende Anschrift", value: "alternative"]
    ]
  end

  def get_changeset_sort_param do
    :postal_adresses_sort
  end

  def get_changeset_drop_param do
    :postal_adresses_drop
  end

  @doc false
  def changeset(postal_address, attrs) do
    postal_address
    |> cast(
      attrs,
      [
        :type,
        :street,
        :street_number,
        :street_additional_information,
        :zipcode,
        :city,
        :country,
        :is_main
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :type,
      :street,
      :street_number,
      :zipcode,
      :city,
      :country
    ])
    |> update_change(:street, &String.trim/1)
    |> update_change(:street_number, &String.trim/1)
    |> update_change(:street_additional_information, &String.trim/1)
    |> update_change(:zipcode, &String.trim/1)
    |> update_change(:city, &String.trim/1)
    |> validate_length(:street, max: 100)
    |> validate_length(:street_number, max: 30)
    |> validate_length(:street_additional_information, max: 100)
    |> validate_length(:city, max: 100)
    |> validate_inclusion(
      :country,
      get_valid_countries() |> Enum.map(fn country -> country[:value] end)
    )
    |> validate_zipcode()
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
  end

  defp validate_zipcode(%Ecto.Changeset{} = changeset) do
    zipcode_length =
      case get_field(changeset, :country) do
        "DEU" -> 5
        "AUT" -> 4
        "CHE" -> 4
        # high value for default...
        _ -> 10
      end

    changeset
    |> validate_format(:zipcode, ~r/^\d{#{zipcode_length}}$/,
      message: "Es müssen genau #{zipcode_length} Ziffern erfasst werden."
    )
  end
end
