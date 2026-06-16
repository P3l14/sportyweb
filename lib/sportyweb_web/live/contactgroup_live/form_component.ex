defmodule SportywebWeb.ContactGroupLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactGroup
  alias SportywebWeb.ContactGroupLive.ContactGroupForm

  attr :error, :string, default: nil

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
          id="contact_group-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.error :if={@error}>{@error}</.error>
          <.input_grids>
            <.contact_group_name_and_type form={@form} />
            <.header level="2" class="col-span-12 md:col-span-12">
              Mitglieder der Kontaktgruppe
              <.errors_for_lists list_field={@form[:contact_group_contacts]} />
            </.header>
            <.input_grid>
              <.inputs_for :let={contact} field={@form[:contact_group_contacts]}>
                <.element_index_field
                  form_name={@form.name}
                  sort_param={ContactGroup.get_changeset_sort_param()}
                  element={contact}
                />
                <%!-- <input
                  type="hidden"
                  name={"contact_group[contacts][#{contact.index}][club_id]"}
                  value={@contact_group.club_id}
                /> --%>
                <div class="col-span-12 md:col-span-11">
                  <.input
                    field={contact[:contact_id]}
                    type="select"
                    label="Kontakt"
                    options={@contact_options}
                    prompt="Bitte auswählen"
                  />
                </div>
                <.element_delete_button
                  form_name={@form.name}
                  drop_param={ContactGroup.get_changeset_drop_param()}
                  class="col-span-12 md:col-span-1 mt-9"
                  element={contact}
                />
              </.inputs_for>
              <.element_add_button
                form_name={@form.name}
                sort_param={ContactGroup.get_changeset_sort_param()}
                class="col-span-12"
              />
            </.input_grid>
          </.input_grids>
          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@contact_group_form.contact_group.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @contact_group_form.contact_group.id})}
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

  def contact_group_name_and_type(assigns) do
    ~H"""
    <.inputs_for :let={contact_group} field={@form[:contact_group]}>
      <.input_grid>
        <div class="col-span-12 md:col-span-12">
          <.input field={contact_group[:name]} type="text" label="Gruppenname" />
        </div>
        <div class="col-span-12 md:col-span-12">
          <.input
            field={contact_group[:type]}
            type="select"
            label="Art"
            options={ContactGroup.get_valid_types()}
          />
        </div>
      </.input_grid>
    </.inputs_for>
    """
  end

  @impl true
  def update(%{contact_group_form: contact_group_form} = assigns, socket) do
    changeset = ContactGroupForm.changeset(contact_group_form)

    contact_options =
      Personal.list_contacts_for_contact_group_selection(
        contact_group_form.contact_group.club_id,
        contact_group_form.contact_group_contacts
        |> Enum.map(fn contact_group_contacts -> contact_group_contacts.contact_id end)
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :contact_options,
       contact_options |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)
     )
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"contact_group_form" => contact_group_form_params},
        %{assigns: %{contact_options: contact_options}} = socket
      ) do
    changeset =
      ContactGroupForm.changeset(socket.assigns.contact_group_form, contact_group_form_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(:contact_options, contact_options)}
  end

  def handle_event("save", %{"contact_group_form" => contact_group_form_params}, socket) do
    save_contact_group(socket, socket.assigns.action, contact_group_form_params)
  end

  defp save_contact_group(
         %{assigns: %{contact_group_form: contact_group_form}} = socket,
         :edit,
         %{
           "contact_group" => _,
           "contact_group_contacts" => _
         } = contact_group_form_params
       ) do
    changeset =
      ContactGroupForm.changeset(socket.assigns.contact_group_form, contact_group_form_params)

    if changeset.valid? do
      case Personal.update_contact_group_with_contact_group_contacts(
             contact_group_form,
             contact_group_form_params
           ) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Kontaktgruppe erfolgreich aktualisiert")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, _, %Ecto.Changeset{}, _} ->
          # Errors can not be easily mappend backword. The validation takes places via the changeset
          # This message ist the last resort if everything fails, so the user is informed about the crash.
          {:noreply,
           socket
           |> assign(:error, "Beim Aktualisieren der Kontaktgruppe ist ein Fehler aufgetreten!")}
      end
    else
      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :validate))}
    end
  end

  defp save_contact_group(
         %{assigns: %{contact_group_form: contact_group_form}} = socket,
         :new,
         contact_group_form_params
       ) do
    contact_group_form_params =
      contact_group_form_params
      |> put_in(
        ["contact_group", "club_id"],
        contact_group_form.contact_group.club_id
      )

    changeset =
      ContactGroupForm.changeset(socket.assigns.contact_group_form, contact_group_form_params)

    %{
      "contact_group" => contact_group_params,
      "contact_group_contacts" => contact_group_contact_params
    } = contact_group_form_params

    if changeset.valid? do
      case Personal.create_contact_group_with_contact_group_contacts(
             contact_group_params,
             contact_group_contact_params
           ) do
        {:ok, _} ->
          {:noreply,
           socket
           |> put_flash(:info, "Kontaktgruppe erfolgreich erstellt")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, _, %Ecto.Changeset{}, _} ->
          # Errors can not be easily mappend backword. The validation takes places via the changeset
          # This message ist the last resort if everything fails, so the user is informed about the crash.
          {:noreply,
           socket
           |> assign(:error, "Beim Anlegen der Kontaktgruppe ist ein Fehler aufgetreten!")}
      end
    else
      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :validate))}
    end
  end
end
