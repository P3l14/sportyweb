defmodule Sportyweb.Personal.ContactRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Personal.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_roles" do
    belongs_to :contact, Contact
    field :name, :string, default: nil
    field :valid_from, :date, default: nil
    field :valid_until, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_valid_names do
    [
      [key: "Erziehungsberechtigter", value: "legal guardian"],
      [key: "Interessent", value: "interested"],
      [key: "Kursteilnehmer", value: "participants"],
      [key: "Lieferant", value: "supplier"],
      [key: "Spender", value: "donor"],
      [key: "Sponsor", value: "sponsor"],
      [key: "Veranstaltungsbesucher", value: "visitor"]
    ]
  end

  def get_changeset_sort_param do
    :contact_roles_sort
  end

  def get_changeset_drop_param do
    :contact_roles_drop
  end

  @doc false
  def changeset(contact_role, attrs) do
    contact_role
    |> cast(attrs, [:valid_from, :valid_until, :name, :contact_id])
    |> validate_required([:valid_from, :name])
    |> validate_inclusion(
      :name,
      get_valid_names() |> Enum.map(fn name -> name[:value] end)
    )
  end
end
