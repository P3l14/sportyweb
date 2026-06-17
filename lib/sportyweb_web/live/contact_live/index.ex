defmodule SportywebWeb.ContactLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index = live_action, %{"club_id" => club_id}) do
    club =
      Organization.get_club!(club_id,
        departments: [:groups]
      )

    # A member is a person with a contract. The contract must not be active.
    contacts = Personal.filter_contacts(club_id, "", "", "", get_mode(live_action))

    socket
    |> assign_common_values("Kontakte", club, :contacts, contacts)
  end

  defp apply_action(socket, :index_member = live_action, %{"club_id" => club_id}) do
    club =
      Organization.get_club!(club_id,
        departments: [:groups]
      )

    # A member is a person with a contract. The contract must not be active.
    contacts = Personal.filter_contacts(club_id, "", "", "", get_mode(live_action))

    socket
    |> assign(:member_inventory_year, Date.utc_today().year)
    |> assign_common_values("Mitglieder", club, :members, contacts)
  end

  defp assign_common_values(socket, page_title, club, club_navigation_current_item, contacts) do
    number_of_contacts = length(contacts)

    socket
    |> assign(:page_title, page_title)
    |> assign(:club_navigation_current_item, club_navigation_current_item)
    |> assign(:type, club_navigation_current_item)
    |> assign(:club, club)
    |> assign(:contacts_present, Enum.any?(contacts))
    |> assign(:contacts_total, number_of_contacts)
    |> assign(:contacts_shown, number_of_contacts)
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{
          "search" => %{
            "name" => name,
            "type" => type,
            "role" => role,
            "include_archived" => include_archived
          }
        },
        socket
      ) do
    mode = get_mode(socket.assigns.live_action)

    filtered_contacts =
      Personal.filter_contacts(socket.assigns.club.id, name, type, role, mode, include_archived)

    {:noreply,
     socket
     |> assign(:contacts_shown, length(filtered_contacts))
     |> stream(:contacts, filtered_contacts, reset: true)}
  end

  defp get_mode(:index_member) do
    :only_members
  end

  defp get_mode(:index) do
    :only_contacts
  end

  attr :streams, :map, required: true
  attr :club, Sportyweb.Organization.Club, required: true
  attr :live_action, :atom, required: true
  attr :type, :atom, required: true

  def contact_table(assigns) do
    ~H"""
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
        <%= if Contact.has_only_archived_membership_contract?(contact) do %>
          <.icon name="hero-archive-box" class="ml-1 inline-block w-[20px] text-red-800" />
        <% end %>
        <%= if not Contact.has_active_membership_contract?(contact) and Contact.has_only_archived_contact_roles?(contact) do %>
          <.icon name="hero-archive-box" class="ml-1 inline-block w-[20px] text-red-800" />
        <% end %>
      </:col>
      <:col :let={{_id, contact}} label="Art">
        {get_key_for_value(Contact.get_valid_types(), contact.type)}
      </:col>
      <:col :let={{_id, contact}} label="Geschlecht">
        {get_key_for_value(Contact.get_valid_genders(), contact.person_gender)}
      </:col>

      <:col :let={{_id, contact}} label="Geburtsdatum">
        {format_date_field_dmy(contact.person_birthday)}
      </:col>

      <:col :let={{_id, contact}} label="Rollen">
        <%= for contact_role <- contact.contact_roles do %>
          {get_key_for_value(ContactRole.get_valid_names(), contact_role.name) |> truncate_string(15)}
          <.icon
            :if={ContactRole.membership_role?(contact_role.name)}
            name="hero-check-badge"
            class="ml-1 inline-block w-[20px] text-green-800"
          /> <br />
        <% end %>
      </:col>

      <:col
        :let={{_id, contact}}
        :if={@type == :members and not Enum.empty?(@club.departments)}
        label="Abteilungen"
      >
        <%= for department <- Contact.get_departments(contact) do %>
          {format_string_field(department.name) |> truncate_string(10)}
        <% end %>
      </:col>

      <:col
        :let={{_id, contact}}
        :if={
          @type == :members and
            not Enum.empty?(
              @club.departments
              |> Enum.flat_map(fn department -> department.groups end)
            )
        }
        label="Gruppen"
      >
        <%= for group <- Contact.get_groups(contact) do %>
          {format_string_field(group.name) |> truncate_string(10)}
        <% end %>
      </:col>

      <:action :let={{_id, contact}}>
        <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
      </:action>
    </.table>
    """
  end
end
