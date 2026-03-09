defmodule Sportyweb.Directory.Bank do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "banks" do
    field :countrycode, :string, default: ""
    field :name, :string, default: ""
    field :bankcode, :string, default: ""
    field :bic, :string, default: ""
    field :shortname, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bank, attrs) do
    bank
    |> cast(attrs, [:bankcode, :bic, :name, :shortname, :countrycode])
    |> validate_required([:bankcode, :bic, :name, :shortname, :countrycode])
  end
end
