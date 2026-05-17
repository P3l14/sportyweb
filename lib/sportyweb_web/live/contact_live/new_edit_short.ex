defmodule SportywebWeb.ContactLive.NewEditShort do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Personal.ContactRoleRelation
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form for={@form} id="contact-form" phx-change="validate" phx-submit="save">
          <SportywebWeb.ContactLive.FormComponent.contact_grid
            form={@form}
            contact_form_type={:short}
            zipcode_proposals={@zipcode_proposals}
            street_proposals={@street_proposals}
          />
          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>

              <.cancel_button navigate={~p"/clubs/#{@club}/contacts"}>Abbrechen</.cancel_button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @doc """
   Utiltiy function to check if role legal guardian is present on contact.

  """

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact =
      Personal.get_contact!(id, [
        :club,
        :emails,
        :financial_data,
        :phones,
        :postal_addresses,
        :notes,
        :contact_roles
      ])

    socket
    |> assign(:title, "Kontakt bearbeiten")
    |> assign(:contact, contact)
    |> assign_form()
    |> assign(:club, contact.club)
    |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
    |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    contact = %Contact{
      club_id: club.id,
      club: club,
      contact_roles: [%ContactRole{contact_role_relations: [%ContactRoleRelation{}]}],
      postal_addresses: [],
      emails: [],
      phones: [],
      financial_data: [],
      notes: []
    }

    socket
    |> assign(:title, "Kontaktschnellerfassung")
    |> assign(:contact, contact)
    |> assign_form()
    |> assign(:club, club)
    |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
    |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
  end

  def assign_form(socket, contact_params \\ %{}) do
    changeset = Personal.change_short_contact(socket.assigns.contact, contact_params)

    socket
    |> assign(form: Phoenix.Component.to_form(changeset, action: :validate))
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset =
      socket.assigns.contact
      |> Personal.change_short_contact(contact_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    contact_params =
      Enum.into(contact_params, %{
        "club_id" => socket.assigns.contact.club.id
      })

    case Personal.create_short_contact(contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich erstellt")
         |> push_navigate(to: ~p"/clubs/#{socket.assigns.contact.club}/contacts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
