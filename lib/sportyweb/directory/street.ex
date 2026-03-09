defmodule Sportyweb.Directory.Street do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "streets" do
    field :zipcode, :string, default: ""
    field :city, :string, default: ""
    field :street, :string, default: ""
    field :country, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(street, attrs) do
    street
    |> cast(attrs, [:zipcode, :city, :street, :country])
    |> validate_required([:zipcode, :city, :street, :country])
  end
end
