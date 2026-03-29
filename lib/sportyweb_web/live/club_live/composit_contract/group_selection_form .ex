defmodule SportywebWeb.ClubLive.GroupSelection do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :name, :string
    field :fee_id, :binary_id
    field :checked, :boolean
  end

  def changeset(group_selection, attrs \\ %{}) do
    group_selection
    |> cast(attrs, [:id, :name, :fee_id, :checked])
    |> validate_fee_on_checked_item()
  end

  defp validate_fee_on_checked_item(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    if get_field(changeset, :checked) do
      validate_required(changeset, :fee_id)
    else
      changeset
    end
  end
end
