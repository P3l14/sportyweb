defmodule Sportyweb.Polymorphic.Phone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field :type, :string, default: "private"
    field :number, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Mobil", value: "mobile"],
      [key: "Privat", value: "private"],
      [key: "Arbeit", value: "work"],
      [key: "Zentrale", value: "organization"],
      [key: "Fax Privat", value: "fax_private"],
      [key: "Fax Arbeit", value: "fax_work"],
      [key: "Pager", value: "pager"],
      [key: "Andere", value: "other"]
    ]
  end

  def get_changeset_sort_param do
    :phones_sort
  end

  def get_changeset_drop_param do
    :phones_drop
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:type, :number, :is_main], empty_values: ["", nil])
    |> validate_required([:type])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> update_change(:number, &String.trim/1)
    # restricted the input format to numbers and diverse separator charcters
    |> validate_format(:number, ~r/^[0-9\s\/\(\)\+\-\.]+$/)
    |> validate_length(:number, max: 100)
  end
end
