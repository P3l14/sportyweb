defmodule SportywebWeb.ContactLive.InventoryList.InventoryListForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :year, :integer
    field :format, :string
    field :checked, :boolean
  end

  def get_valid_formats do
    [
      "xml",
      "xslx"
    ]
  end

  def changeset(inventory_list_form, attrs \\ %{}) do
    inventory_list_form
    |> cast(attrs, [:year, :format])
    |> validate_required([:year, :format])
    |> validate_number(:year, greater_than: 1990, less_than: 3000)
    |> validate_inclusion(
      :format,
      get_valid_formats() |> Enum.map(fn format -> format end)
    )
  end
end
