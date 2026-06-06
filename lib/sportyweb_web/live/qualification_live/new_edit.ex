defmodule SportywebWeb.QualificationLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Qualification

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.QualificationLive.FormComponent}
        id={@qualification.id || :new}
        title={@page_title}
        action={@live_action}
        contact={@contact}
        qualification={@qualification}
        navigate={
          if @qualification.id,
            do: ~p"/contacts/#{@contact}/qualifications/#{@qualification}",
            else: ~p"/contacts/#{@contact}"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts_menue)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    qualification = Personal.get_qualification!(id, contact: :club)

    socket
    |> assign(:page_title, "Qualifikation bearbeiten")
    |> assign(:contact, qualification.contact)
    |> assign(:club, qualification.contact.club)
    |> assign(:qualification, qualification)
  end

  defp apply_action(socket, :new, %{"contact_id" => contact_id}) do
    contact = Personal.get_contact!(contact_id, :club)

    socket
    |> assign(:page_title, "Qualifikation erstellen")
    |> assign(:contact, contact)
    |> assign(:club, contact.club)
    |> assign(:qualification, %Qualification{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    qualification = Personal.get_qualification!(id)
    {:ok, _} = Personal.delete_qualification(qualification)

    {:noreply,
     socket
     |> put_flash(:info, "Qualifikation erfolgreich gelöscht")
     |> push_navigate(to: "/contacts/#{qualification.contact_id}")}
  end
end
