defmodule SportywebWeb.ContactGroupLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ContactGroupLive.FormComponent}
        id={:new}
        title={@page_title}
        action={@live_action}
        contact_group={@contact_group}
        navigate={
          if @contact_group.id,
            do: ~p"/contact_groups/#{@contact_group}",
            else: ~p"/clubs/#{@club}/contact_groups"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_groups)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact_group = Personal.get_contact_group!(id, [:contacts, :club])

    socket
    |> assign(:page_title, "Kontaktgruppe bearbeiten")
    |> assign(:contact_group, contact_group)
    |> assign(:club, contact_group.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Kontaktgruppe erstellen")
    |> assign(:club, club)
    |> assign(:contact_group, %ContactGroup{
      club_id: club.id,
      contacts: [%Contact{}]
    })
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Personal.get_contact_group!(id)
    {:ok, _} = Personal.delete_contact_group(contact)

    {:noreply,
     socket
     |> put_flash(:info, "Kontaktgruppe erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{contact.club_id}/contact_groups")}
  end
end
