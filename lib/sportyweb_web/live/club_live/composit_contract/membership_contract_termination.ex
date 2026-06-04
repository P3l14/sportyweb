defmodule SportywebWeb.ClubLive.MembershipContractTermination do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias SportywebWeb.ClubLive.MembershipContractTerminationForm
  alias SportywebWeb.ClubLive.ContractSelection

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="membership_contract_termination_form"
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:termination_date]} type="date" label="Kündigungsdatum" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:archive_date]} type="date" label="Vertragsende" />
              </div>
              <.header level="2" class="col-span-12 md:col-span-12 mt-5">
                Mitgliedschaftsverträge
              </.header>
              <.inputs_for :let={contract_selection} field={@form[:contract_selections]}>
                <div class="col-span-12 md:col-span-12">
                  <.input
                    type="checkbox"
                    field={contract_selection[:checked]}
                    label={contract_selection[:name].value}
                  /> <.input type="hidden" field={contract_selection[:name]} />
                  <.input type="hidden" field={contract_selection[:id]} />
                </div>
              </.inputs_for>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern..." class="bg-rose-700 hover:bg-rose-800">
                Mitgliedschaften kündigen
              </.button>

              <.cancel_button navigate={~p"/contacts/#{@contact}"}>Abbrechen</.cancel_button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    contact = Personal.get_contact!(id, [:club, contracts: [:clubs, :departments, :groups]])

    membership_contract_termination_form = %MembershipContractTerminationForm{
      contact_id: contact.id,
      termination_date: Date.utc_today(),
      contract_selections:
        contact.contracts
        |> Enum.filter(fn contract ->
          Contract.is_in_use?(contract) and is_nil(contract.archive_date)
        end)
        |> Enum.map(fn contract ->
          %ContractSelection{
            id: contract.id,
            name: Contract.get_object(contract).name,
            # everything is checked on default because the benefit of the is that all contracts can be easily terminated with the same dates
            checked: true
          }
        end)
    }

    {:noreply,
     socket
     |> assign(:title, "Mitgliedschaften kündigen")
     |> assign(:club, contact.club)
     |> assign(:contact, contact)
     |> assign(:membership_contract_termination_form, membership_contract_termination_form)
     |> assign_new(:form, fn ->
       to_form(MembershipContractTerminationForm.changeset(membership_contract_termination_form))
     end)}
  end

  def assign_form(socket, membership_contract_termination_form) do
    changeset =
      MembershipContractTerminationForm.changeset(
        socket.assigns.membership_contract_termination_form,
        membership_contract_termination_form
      )

    socket
    |> assign(form: to_form(changeset, action: :validate))
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "membership_contract_termination_form" => membership_contract_termination_form
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign_form(membership_contract_termination_form)}
  end

  @impl true
  def handle_event(
        "save",
        %{
          "membership_contract_termination_form" => membership_contract_termination_form
        },
        socket
      ) do
    changeset =
      socket.assigns.membership_contract_termination_form
      |> MembershipContractTerminationForm.changeset(membership_contract_termination_form)

    if changeset.valid? do
      membership_contract_termination_form = Ecto.Changeset.apply_changes(changeset)

      selected =
        membership_contract_termination_form.contract_selections
        |> Enum.filter(fn contract_selection -> contract_selection.checked end)
        |> Enum.map(fn contract_selection -> contract_selection.id end)

      socket.assigns.contact.contracts
      |> Enum.filter(fn contract -> contract.id in selected end)
      |> Enum.each(fn contract ->
        Legal.update_contract(contract, %{
          termination_date: membership_contract_termination_form.termination_date,
          archive_date: membership_contract_termination_form.archive_date
        })
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Mitgliedschaften erfolgreich gekündigt")
       |> push_navigate(to: "/contacts/#{socket.assigns.contact.id}")}
    else
      {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
