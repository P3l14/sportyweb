defmodule SportywebWeb.ClubLive.DepartmentSelection do
  use Ecto.Schema
  import Ecto.Changeset
  alias SportywebWeb.ClubLive.GroupSelection

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :name, :string
    field :fee_id, :binary_id
    field :checked, :boolean
    embeds_many :group_selections, GroupSelection, on_replace: :delete
  end

  def changeset(department_selection, attrs \\ %{}) do
    department_selection
    |> cast(attrs, [:id, :name, :fee_id, :checked])
    |> cast_embed(:group_selections)
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
