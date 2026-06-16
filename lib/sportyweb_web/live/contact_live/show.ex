defmodule SportywebWeb.ContactLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Qualification
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Phone
  import SportywebWeb.QualificationLive.Show

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
        :qualifications,
        :contact_groups,
        :debit_holder,
        :invoice_contact,
        financial_data: [
          :direct_debit_different_account_holder_contact,
          :invoice_different_recipient_contact
        ],
        contact_roles: [contact_role_relations: [:contact, :department, :group]],
        contracts: [:clubs, :departments, :groups, fee: :internal_events],
        contact_role_relations: [contact_role: :contact]
      ])

    debit_users =
      contact.debit_holder
      |> Enum.map(fn financial_data ->
        Personal.get_contact_for_financial_data(financial_data)
      end)

    invoice_users =
      contact.invoice_contact
      |> Enum.map(fn financial_data ->
        Personal.get_contact_for_financial_data(financial_data)
      end)

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{contact.name}")
     |> assign(:contact, contact)
     |> assign(:debit_users, debit_users)
     |> assign(:invoice_users, invoice_users)
     |> assign(:club, contact.club)
     |> stream(:contracts, contact.contracts)
     |> stream(:qualifications, contact.qualifications)}
  end
end
