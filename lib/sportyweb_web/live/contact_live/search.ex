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
    <.card>
      <.header level="2" class="col-span-12 md:col-span-12">
        Suchergebnisse
      </.header>
      <%= if Enum.any?(@streams.contacts.inserts) do %>
        <.table
          id="contacts"
          rows={@streams.contacts}
          row_click={fn {_id, contact} -> JS.navigate(~p"/contacts/#{contact}") end}
        >
          <:col :let={{_id, contact}} label="Name">
            {format_string_field(contact.name)}
            <%= if Contact.has_active_membership_contract?(contact) do %>
              <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-800" />
            <% end %>
          </:col>
          <:col :let={{_id, contact}} label="Art">
            {get_key_for_value(Contact.get_valid_types(), contact.type)}
          </:col>

          <:col :let={{_id, contact}} :if={@live_action == :index} label="Rollen">
            {format_struct_list(contact.contact_roles, :name, fn value ->
              get_key_for_value(ContactRole.get_valid_names(), value)
            end)}
          </:col>

          <:action :let={{_id, contact}}>
            <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
          </:action>
        </.table>
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
    {:noreply, socket |> stream(:contacts, filtered_contacts, reset: true)}
  end
end
