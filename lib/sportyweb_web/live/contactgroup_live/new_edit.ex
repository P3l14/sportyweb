defmodule SportywebWeb.ContactGroupLive.NewEdit do
  alias SportywebWeb.ContactGroupLive.ContactGroupForm
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.ContactGroupContact
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
        contact_group_form={@contact_group_form}
        navigate={
          if @contact_group_form.contact_group.id,
            do: ~p"/contact_groups/#{@contact_group_form.contact_group}",
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
    contact_group_contacts = Personal.get_contact_group_contacts!(contact_group.id)

    socket
    |> assign(:page_title, "Kontaktgruppe bearbeiten")
    |> assign(:club, contact_group.club)
    |> assign(:contact_group_form, %ContactGroupForm{
      contact_group: contact_group,
      contact_group_contacts: contact_group_contacts
    })
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Kontaktgruppe erstellen")
    |> assign(:club, club)
    |> assign(:contact_group_form, %ContactGroupForm{
      contact_group: %ContactGroup{club_id: club.id},
      contact_group_contacts: [%ContactGroupContact{}]
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
