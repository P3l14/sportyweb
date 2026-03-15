defmodule Sportyweb.Polymorphic.PostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "postal_addresses" do
    has_many :financial_data, FinancialData,
      foreign_key: :invoice_recipient_postal_address_id,
      references: :id

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
      [key: "abweichende Rechnungsadresse", value: "billing"],
      [key: "Firmensitz", value: "company headquarters"],
      [key: "abweichende Anschrift", value: "alternative"]
    ]
  end

  def is_form_with_multiples?(form_id) do
    form_id in [
      "contact"
    ]
  end

  def get_changeset_sort_param do
    :postal_adresses_sort
  end

  def get_changeset_drop_param do
    :postal_adresses_emails_drop
  end

  @doc false
  def changeset(postal_address, attrs) do
    postal_address
    |> cast(
      attrs,
      [
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
    |> validate_length(:street, max: 250)
    |> validate_length(:street_number, max: 250)
    |> validate_length(:street_additional_information, max: 250)
    |> validate_length(:zipcode, max: 15)
    |> validate_length(:city, max: 250)
    |> validate_inclusion(
      :country,
      get_valid_countries() |> Enum.map(fn country -> country[:value] end)
    )
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
  end
end
