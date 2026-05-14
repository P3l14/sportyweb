defmodule SportywebWeb.ContactLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
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
    |> assign(:page_title, "Kontakte")
    |> assign(:club_navigation_current_item, :contacts)
    |> assign(:club, club)
    |> assign(:all_contacts, contacts)
    |> stream(:contacts, contacts)
  end

  defp apply_action(socket, :index_member, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, contacts: :contracts)
    # A member is a person with a contract. The contract must not be active.
    contacts =
      club.contacts
      |> Enum.filter(fn contact -> !Enum.empty?(contact.contracts) end)

    socket
    |> assign(:page_title, "Mitglieder")
    |> assign(:club_navigation_current_item, :members)
    |> assign(:club, club)
    |> assign(:all_contacts, contacts)
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => %{"name" => name, "type" => type, "role" => role}},
        socket
      ) do
    filtered_contacts = socket.assigns.all_contacts

    filtered_contacts =
      if type != "" do
        filtered_contacts |> Enum.filter(fn contact -> contact.type == type end)
      else
        filtered_contacts
      end

    filtered_contacts =
      if role != "" do
        filtered_contacts
        |> Enum.filter(fn contact ->
          Enum.any?(contact.contact_roles, fn contact_role -> dbg(contact_role.name == role) end)
        end)
      else
        filtered_contacts
      end

    filtered_contacts =
      filtered_contacts |> Enum.filter(fn contact -> contact.name |> String.contains?(name) end)
    {:noreply, socket |> stream(:contacts, filtered_contacts, reset: true)}
  end
end
