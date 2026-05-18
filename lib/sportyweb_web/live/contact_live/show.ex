defmodule SportywebWeb.ContactLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Phone

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact =
      Personal.get_contact!(id, [
        :club,
        :emails,
        :notes,
        :phones,
        :postal_addresses,
        financial_data: [
          :direct_debit_different_account_holder_contact,
          :invoice_different_recipient_contact
        ],
        contact_roles: [contact_role_relations: [:contact, :department, :group]],
        contracts: [:clubs, :departments, :groups, fee: :internal_events]
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{contact.name}")
     |> assign(:contact, contact)
     |> assign(:club, contact.club)
     |> stream(:contracts, contact.contracts)}
  end
end
