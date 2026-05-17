defmodule SportywebWeb.ContactLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note

  attr :contact_form_type, :atom, required: false
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="contact-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.contact_grid
            form={@form}
            contact_form_type={@contact_form_type}
            zipcode_proposals={@zipcode_proposals}
            street_proposals={@street_proposals}
            contacts_for_different_holder_or_recipient={@contacts_for_different_holder_or_recipient}
          />

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>

              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@contact.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @contact.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  attr :form, :map, required: true
  attr :contact_form_type, :atom, required: false
  attr :render_roles, :boolean, required: false, default: true
  attr :zipcode_proposals, :list, required: false, default: []
  attr :street_proposals, :list, required: false, default: []
  attr :contacts_for_different_holder_or_recipient, :list, required: false, default: []

  slot :additional_personal_components, required: false

  def contact_grid(assigns) do
    ~H"""
    <.input_grids>
      <.input_grid>
        <div class="col-span-12">
          <!-- Don't remove the id of the div, otherwise LiveView doesn't remove the input in step 2. -->
          <.input field={@form[:type]} type="select" label="Art" options={Contact.get_valid_types()} />
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
            <.input field={@form[:person_first_name]} type="text" label="Vorname" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input
              field={@form[:person_middle_names]}
              type="text"
              label="weitere Vornamen (optional)"
            />
          </div>
          <!-- für kurzkontakt steuerbar machen -->
          <%= if @contact_form_type == :full do %>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_birth_name]} type="text" label="Geburtsname (optional)" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input
                field={@form[:person_gender]}
                type="select"
                label="Geschlecht"
                options={Contact.get_valid_genders()}
                prompt="Bitte auswählen"
              />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_birthday]} type="date" label="Geburtsdatum" />
            </div>
          <% end %>
          <%= if @contact_form_type == :short do %>
            <div :if={has_legal_guardian_role?(@form)} class="col-span-12 md:col-span-4">
              <.input field={@form[:person_birthday]} type="date" label="Geburtsdatum" />
            </div>
          <% end %>
        </.input_grid>
      <% end %>

      {render_slot(@additional_personal_components)}

      <.input_grid :if={@render_roles}>
        <SportywebWeb.ContactLive.ContactRoleFormComponent.render form={@form} allow_multiple={true} />
      </.input_grid>

      <.input_grid class="pt-6">
        <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render
          form={@form}
          allow_multiple={true}
          zipcode_proposals={@zipcode_proposals}
          street_proposals={@street_proposals}
        />
      </.input_grid>

      <.input_grid class="pt-6">
        <SportywebWeb.PolymorphicLive.EmailsFormComponent.render form={@form} allow_multiple={true} />
      </.input_grid>

      <.input_grid class="pt-6">
        <SportywebWeb.PolymorphicLive.PhonesFormComponent.render form={@form} allow_multiple={true} />
      </.input_grid>

      <.input_grid class="pt-6">
        <SportywebWeb.PolymorphicLive.FinancialDataFormComponent.render
          form={@form}
          allow_multiple={true}
          contacts_for_different_holder_or_recipient={@contacts_for_different_holder_or_recipient}
        />
      </.input_grid>

      <.input_grid class="pt-6">
        <SportywebWeb.PolymorphicLive.NotesFormComponent.render form={@form} allow_multiple={true} />
      </.input_grid>
    </.input_grids>
    """
  end

  def has_legal_guardian_role?(form) do
    contact_roles = form[:contact_roles].value || []

    contact_role_names =
      Enum.map(contact_roles, fn
        %Ecto.Changeset{} = changeset -> Ecto.Changeset.get_field(changeset, :name)
        %{} = contact_role -> contact_role.name
      end)

    "legal guardian" in contact_role_names
  end

  @impl true
  def update(%{contact: contact} = assigns, socket) do
    # Need to initialize financial_data and notes for contacts created with create_short contact.
    # The changes must be made before the changeset is created otherwise ecto will not recognize thet the elements are new.
    contact =
      if !is_nil(contact.id) and Enum.empty?(contact.financial_data) do
        %{contact | financial_data: [%FinancialData{}]}
      else
        contact
      end

    contact =
      if !is_nil(contact.id) and Enum.empty?(contact.notes) do
        %{contact | notes: [%Note{}]}
      else
        contact
      end

    changeset = Personal.change_contact(contact)

    contacts_for_different_holder_or_recipient =
      assigns.contact.club_id
      |> Personal.list_contacts()
      |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :contacts_for_different_holder_or_recipient,
       contacts_for_different_holder_or_recipient
     )
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)
     |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2
     )
     |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2
     )}
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    {:noreply,
     socket
     |> assign_form(contact_params)}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    save_contact(socket, socket.assigns.action, contact_params)
  end

  def assign_form(socket, contact_params) do
    changeset = Personal.change_contact(socket.assigns.contact, contact_params)

    socket
    |> assign(form: to_form(changeset, action: :validate))
  end

  defp save_contact(socket, :edit, contact_params) do
    case Personal.update_contact(socket.assigns.contact, contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contact(socket, :new, contact_params) do
    contact_params =
      Enum.into(contact_params, %{
        "club_id" => socket.assigns.contact.club.id
      })

    case Personal.create_contact(contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
