defmodule SportywebWeb.ContactLive.NewEditShort do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form for={@form} id="contact-form" phx-change="validate" phx-submit="save">
          <.input_grids>
            <.input_grid class="pt-6">
              <SportywebWeb.ContactLive.ContactRoleFormComponent.render
                form={@form}
                allow_multiple={true}
              />
            </.input_grid>
            <.input_grid>
              <div class="col-span-12">
                <!-- Don't remove the id of the div, otherwise LiveView doesn't remove the input in step 2. -->
                <.input
                  field={@form[:type]}
                  type="select"
                  label="Art"
                  options={Contact.get_valid_types()}
                />
              </div>
            </.input_grid>

            <%= if @form[:type].value == "organization" do %>
              <.header level="2" class="col-span-12 md:col-span-12">
                Organisationsdaten
              </.header>
              <.input_grid>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:organization_name]} type="text" label="Organisationsname" />
                </div>

                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:organization_type]}
                    type="select"
                    label="Organisationstyp"
                    options={Contact.get_valid_organization_types()}
                    prompt="Bitte auswählen"
                  />
                </div>
              </.input_grid>
            <% else %>
              <.header level="2" class="col-span-12 md:col-span-12">
                Personendaten
              </.header>
              <.input_grid>
                <div class="col-span-12 md:col-span-4">
                  <.input field={@form[:person_last_name]} type="text" label="Nachname" />
                </div>

                <div class="col-span-12 md:col-span-4">
                  <.input field={@form[:person_first_name_1]} type="text" label="Vorname" />
                </div>

                <div class="col-span-12 md:col-span-4">
                  <.input
                    field={@form[:person_first_name_2]}
                    type="text"
                    label="2. Vorname (optional)"
                  />
                </div>
              </.input_grid>
            <% end %>
            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render
                form={@form}
                allow_multiple={true}
                zipcode_proposals={@zipcode_proposals}
                street_proposals={@street_proposals}
              />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.EmailsFormComponent.render
                form={@form}
                allow_multiple={true}
              />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.PhonesFormComponent.render
                form={@form}
                allow_multiple={true}
              />
            </.input_grid>
          </.input_grids>

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
        :roles
      ])

    socket
    |> assign(:title, "Kontakt bearbeiten")
    |> assign(:contact, contact)
    |> assign(:form, Phoenix.Component.to_form(Personal.change_short_contact(contact)))
    |> assign(:club, contact.club)
    |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    contact = %Contact{
      club_id: club.id,
      club: club,
      roles: [%ContactRole{}],
      postal_addresses: [],
      emails: [],
      phones: [],
      financial_data: [],
      notes: []
    }

    socket
    |> assign(:title, "Kontaktschnellerfassung")
    |> assign(:contact, contact)
    |> assign(:form, Phoenix.Component.to_form(Personal.change_short_contact(contact)))
    |> assign(:club, club)
    |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
      &assign_form/2
    )
  end

  def assign_form(socket, contact_params) do
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
