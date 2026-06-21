defmodule SportywebWeb.ContractLive.Edit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ContractLive.FormComponent}
        id={@contract.id}
        title={@page_title}
        action={@live_action}
        contract={@contract}
        contract_object={@contract_object}
        navigate={
          if @contract.id, do: ~p"/contracts/#{@contract}", else: ~p"/departments/#{@department}"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :fees)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # There is no "new" action in this LiveView because that gets handled in the corresponding LiveView for contracts to club, department and group SportywebWeb.ContractLive.NewEdit

  defp apply_action(socket, :edit, %{"id" => id}) do
    contract =
      Legal.get_contract!(id, [
        :club,
        :contact,
        :fee,
        :clubs,
        departments: [:fees],
        groups: [:fees]
      ])

    contract_object = contract |> Contract.get_object()
    contract_object = Sportyweb.Repo.preload(contract_object, :contracts)

    socket
    |> assign(:page_title, page_title(contract_object))
    |> assign(:contract, contract)
    |> assign(:contract_object, contract_object)
    |> assign(:club, contract.club)
    |> assign(:club_navigation_current_item, club_navigation_current_item(contract_object))
  end

  defp page_title(contract_object)

  defp page_title(%Club{}) do
    "Mitgliedschaftsvertrag bearbeiten (Verein)"
  end

  defp page_title(%Department{name: name}) do
    "Mitgliedschaftsvertrag bearbeiten (Abteilung: #{name})"
  end

  defp page_title(%Group{name: name}) do
    "Mitgliedschaftsvertrag bearbeiten (Gruppe: #{name})"
  end

  defp page_title(_contract_object) do
    "Vertrag bearbeiten"
  end

  defp club_navigation_current_item(contract_object)

  defp club_navigation_current_item(%Club{}) do
    :members
  end

  defp club_navigation_current_item(%Department{}) do
    :members
  end

  defp club_navigation_current_item(%Group{}) do
    :members
  end

  defp club_navigation_current_item(_contract_object) do
    :fees
  end
end
