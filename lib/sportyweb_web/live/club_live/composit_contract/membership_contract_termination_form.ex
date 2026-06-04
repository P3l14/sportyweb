defmodule SportywebWeb.ClubLive.MembershipContractTerminationForm do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations
  alias SportywebWeb.ClubLive.ContractSelection

  @primary_key false
  embedded_schema do
    field :contact_id, :string, default: nil
    field :termination_date, :date, default: nil
    field :archive_date, :date, default: nil
    embeds_many :contract_selections, ContractSelection, on_replace: :delete
  end

  def changeset(membership_contract_termination_form, attrs \\ %{}) do
    membership_contract_termination_form
    |> cast(attrs, [
      :contact_id,
      :termination_date,
      :archive_date
    ])
    |> validate_required([:contact_id, :termination_date, :archive_date])
    |> cast_embed(:contract_selections)
    |> validate_dates_order(
      :termination_date,
      :archive_date,
      "Muss zeitlich später als oder gleich \"Kündigungsdatum\" sein!"
    )
  end
end
