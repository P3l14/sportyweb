defmodule SportywebWeb.ContactLive.InventoryList.InventoryListForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :year, :integer
    field :type, :string
    field :checked, :boolean
  end

  def get_valid_types do
    [
      "XML",
      "XLSX"
    ]
  end

  def changeset(inventory_list_form, attrs \\ %{}) do
    inventory_list_form
    |> cast(attrs, [:year, :type])
    |> validate_required([:year, :type])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type end)
    )
  end
end
