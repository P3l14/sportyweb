defmodule SportywebWeb.ContractLive.Edit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal

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
    {:ok, assign(socket, :club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # There is no "new" action in this LiveView because that gets handled in the corresponding LiveView for contracts to club, department and group SportywebWeb.ContractLive.NewEdit

  defp apply_action(socket, :edit, %{"id" => id}) do
    contract =
      Legal.get_contract!(id, [:contact, :fee, :clubs, departments: [:fees], groups: [:fees]])

    contract_object = contract |> Contract.get_object()
    contract_object = Sportyweb.Repo.preload(contract_object, :contracts)
    # club = department.club

    socket
    |> assign(:page_title, "Mitgliedschaftsvertrag bearbeiten")
    |> assign(:contract, contract)
    |> assign(:contract_object, contract_object)

    # |> assign(:department, department)
    # |> assign(:club, club)
  end
end
