defmodule SportywebWeb.ContactGroupLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_groups)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact_group = Personal.get_contact_group!(id, [:contacts, :club])

    {:noreply,
     socket
     |> assign(:page_title, "Kontaktgruppe: #{contact_group.name}")
     |> assign(:contact_group, contact_group)
     |> assign(:club, contact_group.club)}
  end
end
