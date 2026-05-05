defmodule SportywebWeb.ContactLive.FormComponent do
  require IEx
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note

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
          <.input_grids>
            <%= if @step == 1 do %>
              <.input_grid>
                <div class="col-span-12" id="step-1-type">
                  <!-- Don't remove the id of the div, otherwise LiveView doesn't remove the input in step 2. -->
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={Contact.get_valid_types()}
                  />
                </div>
              </.input_grid>
            <% end %>

            <%= if @step == 2 do %>
              <div class="hidden">
                <!-- added id and name attribute so the stored value is delivered to the server and can be wrote back, so the correct form in case of organization is displayed after the validate event -->
                <input
                  name="contact[type]"
                  id="contact_type"
                  value={@form[:type].value}
                  field={@form[:type].value}
                  type="hidden"
                  readonly
                />
              </div>

              <%= if @contact_type == "organization" do %>
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

                  <div class="col-span-12 md:col-span-4">
                    <.input
                      field={@form[:person_birth_name]}
                      type="text"
                      label="Geburtsname (optional)"
                    />
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
                </.input_grid>
              <% end %>

              <.input_grid>
                <SportywebWeb.ContactLive.ContactRoleFormComponent.render
                  form={@form}
                  allow_multiple={true}
                />
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

              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.FinancialDataFormComponent.render form={@form} />
              </.input_grid>

              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.NotesFormComponent.render form={@form} />
              </.input_grid>
            <% end %>
          </.input_grids>

          <:actions>
            <div>
              <%= if @step == 1 && @contact_type != "" do %>
                <.button
                  id="next-button"
                  type="button"
                  phx-target={@myself}
                  phx-click={JS.push("update_step", value: %{step: 2})}
                >
                  Weiter
                </.button>
              <% end %>

              <%= if @step == 2 do %>
                <.button phx-disable-with="Speichern...">Speichern</.button>
              <% end %>

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

    step =
      if !is_nil(contact.id) ||
           (get_field(changeset, :step) == 1 && get_field(changeset, :type) != "") do
        2
      else
        1
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:step, step)
     |> assign(:contact_type, contact.type)
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

  @impl true
  def handle_event("update_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, :step, step)}
  end

  def assign_form(socket, contact_params) do
    changeset = Personal.change_contact(socket.assigns.contact, contact_params)

    socket
    |> assign(:contact_type, get_field(changeset, :type))
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
