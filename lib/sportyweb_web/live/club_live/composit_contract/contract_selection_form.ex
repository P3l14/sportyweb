defmodule SportywebWeb.ClubLive.ContractSelection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :name, :string
    field :checked, :boolean
  end

  def changeset(contract_selection, attrs \\ %{}) do
    contract_selection
    |> cast(attrs, [:id, :name, :checked])
  end
end
