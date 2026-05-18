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

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, contacts: [:contracts, :contact_roles])

    contacts =
      club.contacts
      |> Enum.filter(fn contact -> Enum.empty?(contact.contracts) end)

    socket
    |> assign_common_values("Kontakte", club, :contacts, contacts)
  end

  defp apply_action(socket, :index_member, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, contacts: :contracts)
    # A member is a person with a contract. The contract must not be active.
    contacts =
      club.contacts
      |> Enum.filter(fn contact -> !Enum.empty?(contact.contracts) end)

    socket
    |> assign_common_values("Mitglieder", club, :members, contacts)
  end

  defp assign_common_values(socket, page_title, club, club_navigation_current_item, contacts) do
    number_of_contacts = length(contacts)

    socket
    |> assign(:page_title, page_title)
    |> assign(:club_navigation_current_item, club_navigation_current_item)
    |> assign(:club, club)
    |> assign(:contacts_present, Enum.any?(contacts))
    |> assign(:contacts_total, number_of_contacts)
    |> assign(:contacts_shown, number_of_contacts)
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => %{"name" => name, "type" => type, "role" => role}},
        socket
      ) do
    mode =
      if socket.assigns.live_action == :index_member do
        :only_members
      else
        :only_contacts
      end

    filtered_contacts = Personal.filter_contacts(socket.assigns.club.id, name, type, role, mode)

    {:noreply,
     socket
     |> assign(:contacts_shown, length(filtered_contacts))
     |> stream(:contacts, filtered_contacts, reset: true)}
  end
end
