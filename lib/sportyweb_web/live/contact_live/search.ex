defmodule SportywebWeb.ContactLive.Search do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>

    <.card>
      <search>
        <.header level="2" class="col-span-12 md:col-span-12">
          Suchkriterien
        </.header>
        <.simple_form :let={f} for={%{}} as={:search} phx-submit="search">
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6 ml-10">
                <.input field={f[:name]} type="search" label="Name" phx-debounce="1000" />
              </div>
              <div class="col-span-12 md:col-span-3">
                <.input
                  field={f[:type]}
                  type="select"
                  label="Art"
                  options={Contact.get_valid_types()}
                  prompt="Alle"
                  phx-debounce="1000"
                />
              </div>
              <div class="col-span-12 md:col-span-3">
                <.input
                  field={f[:role]}
                  type="select"
                  label="Rolle"
                  options={ContactRole.get_valid_names()}
                  prompt="Alle"
                  phx-debounce="1000"
                />
              </div>
              <div class="col-span-12 md:col-span-3 ml-10"></div>
            </.input_grid>
          </.input_grids>
          <:actions>
            <div>
              <.button phx-disable-with="Suchen...">Suchen</.button>
              <.button type="reset">Filter zurücksetzen</.button>
            </div>
          </:actions>
        </.simple_form>
      </search>
    </.card>
    <.card class="mt-5">
      <.header level="2" class="col-span-12 md:col-span-12">
        Suchergebnisse
      </.header>
      <%= if Enum.any?(@streams.contacts.inserts) do %>
        <p>Es wurden {@hits} Kontakte gefunden</p>
        <.card :for={{_id, contact} <- @streams.contacts} class="mt-5">
          <.list>
            <:item title="Art">
              {get_key_for_value(Contact.get_valid_types(), contact.type)}
            </:item>
            <:item title="Name">
              {format_string_field(contact.name)}
            </:item>
            <:item title="Geburtsname">
              {format_string_field(contact.person_birth_name)}
            </:item>
            <:item :if={Contact.is_organization?(contact)} title="Organisationstyp">
              {get_key_for_value(Contact.get_valid_organization_types(), contact.organization_type)}
            </:item>
            <:item :if={Contact.is_person?(contact)} title="Geschlecht">
              {get_key_for_value(Contact.get_valid_genders(), contact.person_gender)}
            </:item>
            <:item :if={Contact.is_person?(contact)} title="Geburtsdatum">
              {format_date_field_dmy(contact.person_birthday)} - {Contact.age_in_years(contact)} Jahre
            </:item>
            <%!-- <:item title="Adresse">
              <SportywebWeb.PolymorphicLive.PostalAddressesShowComponent.render postal_addresses={
                contact.postal_addresses
              } />
            </:item>
            <:item title="E-Mail">
              <div :for={email <- contact.emails} class="divide-y divide-zinc-100">
                {get_key_for_value(Email.get_valid_types(), email.type)}: {format_string_field(
                  email.address
                )}
              </div>
            </:item>
            <:item title="Telefon">
              <div :for={phone <- contact.phones} class="divide-y divide-zinc-100">
                {get_key_for_value(Phone.get_valid_types(), phone.type)}: {format_string_field(
                  phone.number
                )}
              </div>
            </:item>
            <:item title="Zahlungsdaten">
              <SportywebWeb.PolymorphicLive.FinancialDataShowComponent.render financial_data={
                contact.financial_data
              } />
            </:item>
            <:item title="Notizen">
              <SportywebWeb.PolymorphicLive.NotesShowComponent.render notes={contact.notes} />
            </:item>
            <:item title="Rollen">
              <SportywebWeb.ContactLive.ContactRoleShowComponent.render contact_roles={
                contact.contact_roles
              } />
            </:item>
            <:item :if={Contact.has_active_membership_contract?(contact)} title="Aktives Mitglied">
              <.icon name="hero-check-badge" class="inline-block w-[20px] text-green-800" />
            </:item>
            <:item title="Angelegt am">
              {format_date_time_field_dmy_hms(contact.inserted_at)}
            </:item>
            <:item title="Zuletzt geändert am">
              {format_date_time_field_dmy_hms(contact.updated_at)}
            </:item> --%>
          </.list>
        </.card>
      <% else %>
        <p>
          Zu den Suchkriterien wurde kein Kontakt gefunden!
        </p>
      <% end %>
    </.card>

    <div :if={@live_action == :index_member} class="mt-4 flex align-middle">
      <.icon name="hero-check-badge" class="mr-1 inline-block w-[20px] text-green-800" /> Mitglied
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_search)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :search, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, contacts: [:contracts, :contact_roles])
    contacts = []

    socket
    |> assign(:page_title, "Kontaktsuche")
    |> assign(:club_navigation_current_item, :contact_search)
    |> assign(:club, club)
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => %{"name" => name, "type" => type, "role" => role}},
        socket
      ) do
    filtered_contacts = Personal.filter_contacts(socket.assigns.club.id, name, type, role)

    {:noreply,
     socket
     |> assign(:hits, length(filtered_contacts))
     |> stream(:contacts, filtered_contacts, reset: true)}
  end
end
