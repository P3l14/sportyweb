defmodule SportywebWeb.ContactLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  import SportywebWeb.CommonHelper

  attr :contact_form_type, :atom, required: false
  attr :propably_duplicate_contacts, :list, required: false, default: []
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
            propably_duplicate_contacts={@propably_duplicate_contacts}
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

  @doc """
  Provides html for the input of a contact,
  Can be customized by various paramters


  """
  attr :form, :map, required: true
  attr :contact_form_type, :atom, required: false
  attr :render_roles, :boolean, required: false, default: true
  attr :zipcode_proposals, :list, required: false, default: []
  attr :street_proposals, :list, required: false, default: []
  attr :contacts_for_different_holder_or_recipient, :list, required: false, default: []
  attr :propably_duplicate_contacts, :list, required: false, default: []

  slot :additional_actions_for_dupplicate_contacts, required: false
  slot :additional_personal_components, required: false

  def contact_grid(assigns) do
    ~H"""
    <%= if Enum.any?(@propably_duplicate_contacts) do %>
      <.warning>
        Zu den erfassten Namensdaten wurden folgende Kontakte gefunden.<br />
        Bitte prüfen Sie ob einer dieser Kontakte identisch mit dem Kontakt ist, der gerade erfasst werden soll.
      </.warning>
      <div :for={duplicate_contact <- @propably_duplicate_contacts} class="divide-y divide-zinc-100">
        <.link navigate={~p"/contacts/#{duplicate_contact}"} class="text-indigo-600 hover:underline">
          {format_string_field(duplicate_contact.name)}
        </.link>
        {render_slot(@additional_actions_for_dupplicate_contacts, dbg(duplicate_contact))}
      </div>
    <% end %>
    <.input_grids>
      <.contact_name_data_grid form={@form} contact_form_type={@contact_form_type} />
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

  attr :form, :map, required: true
  attr :contact_form_type, :atom, required: false

  def contact_name_data_grid(assigns) do
    ~H"""
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
          <.input field={@form[:person_middle_names]} type="text" label="weitere Vornamen (optional)" />
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

    {:ok,
     socket
     |> assign(assigns)
     |> assign_contacts_for_different_holder_or_recipient(assigns.contact.club_id)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)
     |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2
     )
     |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2
     )
     |> setup_contact_duplicate_check_event_hook()}
  end

  def assign_contacts_for_different_holder_or_recipient(socket, club_id) do
    socket
    |> assign(
      :contacts_for_different_holder_or_recipient,
      club_id
      |> Personal.list_contacts()
      |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)
    )
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

  @doc """
  Registers a hook on the validate event to check for duplicate contacts upon enterning names for the contact.

  The optional function parameter must be provided when the contact paramter data map is not below the key "contact".
  The function parameter takes the parameter map as input und should return the map with the contact data.


  """
  def setup_contact_duplicate_check_event_hook(
        socket,
        parameter_contact_form_supplying_function \\ fn parameter -> parameter["contact"] end
      )
      when is_function(parameter_contact_form_supplying_function) do
    socket
    |> Phoenix.LiveView.Lifecycle.attach_hook(
      :contact_duplicate_check,
      :handle_event,
      fn
        "validate",
        %{
          "_target" => target
        } = parameter,
        socket ->
          # the last element in _target list is the changed field
          name_of_changed_field = List.first(Enum.reverse(target))

          {:cont,
           socket
           |> check_duplicates(
             name_of_changed_field,
             parameter_contact_form_supplying_function.(parameter)
           )}

        _event, _params, socket ->
          {:cont, socket}
      end
    )
  end

  defp check_duplicates(
         socket,
         name_of_changed_field,
         %{
           "person_last_name" => person_last_name,
           "person_first_name" => person_first_name
         } = parameter
       )
       when name_of_changed_field in ["person_birthday", "person_last_name", "person_first_name"] and
              byte_size(person_last_name) > 2 and
              byte_size(person_first_name) > 2 do
    # removed person_birthday from matching because this field is missing on short contact
    person_birthday = Map.get(parameter, "person_birthday", "")

    propably_duplicate_contacts =
      Personal.find_person_contacts(
        socket.assigns.contact.club_id,
        person_last_name,
        person_first_name,
        person_birthday
      )

    socket
    |> assign(:propably_duplicate_contacts, propably_duplicate_contacts)
  end

  defp check_duplicates(socket, name_of_changed_field, %{"organization_name" => organization_name})
       when name_of_changed_field == "organization_name" and byte_size(organization_name) > 2 do
    propably_duplicate_contacts =
      Personal.find_organization_contacts(
        socket.assigns.contact.club_id,
        organization_name
      )

    socket
    |> assign(:propably_duplicate_contacts, propably_duplicate_contacts)
  end

  defp check_duplicates(socket, _name_of_changed_field, _contact) do
    socket
  end
end
