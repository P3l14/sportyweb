defmodule SportywebWeb.ContactGroupLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactGroup
  alias SportywebWeb.ContactGroupLive.ContactGroupForm

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>
      <.simple_form
        for={@form}
        id="contact_group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.card>
          <.input_grids>
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
            <.header level="2" class="col-span-12 md:col-span-12">
              Mitglieder der Kontaktgruppe
            </.header>
            <.input_grid>
              <.inputs_for :let={contact} field={@form[:contact_group_contacts]}>
                <.element_index_field
                  form_id={@form.id}
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
                  form_id={@form.id}
                  drop_param={ContactGroup.get_changeset_drop_param()}
                  class="col-span-12 md:col-span-1 mt-9"
                  element={contact}
                />
              </.inputs_for>
              <.element_add_button
                form_id={@form.id}
                sort_param={ContactGroup.get_changeset_sort_param()}
                class="col-span-12"
              />
            </.input_grid>
          </.input_grids>
        </.card>
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
    </div>
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

    # tried to exclude currently selected contacts from selection but lead to removal of the selected values
    # current_selected_contacts = contact_group_form_params
    # |>Map.get("contacts")
    # |>Map.values()
    # |>Enum.map(fn contact -> contact|>Map.get("id") end)
    # contact_options = contact_options
    # |>Enum.reject(fn contact -> contact.id in current_selected_contacts end)
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
           "contact_group" => contact_group_params,
           "contact_group_contacts" => contact_group_contact_params
         }
       ) do
    case Personal.update_contact_group(contact_group_form.contact_group, contact_group_params) do
      {:ok, _contact_group} ->
        actual_contact_group_contacts =
          contact_group_contact_params
          |> Map.values()
          |> Enum.map(fn contact_group_contact ->
            Map.get(contact_group_contact, "contact_id")
          end)

        previous_contact_group_contacts =
          contact_group_form.contact_group_contacts
          |> Enum.map(fn contact_group_contact -> contact_group_contact.contact_id end)

        not_anymore_in_contact_group =
          previous_contact_group_contacts
          |> Enum.filter(fn id -> id not in actual_contact_group_contacts end)

        Personal.delete_contact_group_contacts(not_anymore_in_contact_group)

        added_to_contact_group =
          actual_contact_group_contacts
          |> Enum.filter(fn id -> id not in previous_contact_group_contacts end)

        # TODO Fehler auswerten
        results =
          added_to_contact_group
          |> Enum.map(fn id ->
            %{"contact_id" => id, "contact_group_id" => contact_group_form.contact_group.id}
          end)
          |> Enum.map(fn contact_group_contact ->
            contact_group_contact |> Personal.create_contact_group_contact()
          end)

        {:noreply,
         socket
         |> put_flash(:info, "Kontaktgruppe erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contact_group(%{assigns: %{contact_group_form: contact_group_form}} = socket, :new, %{
         "contact_group" => contact_group_params,
         "contact_group_contacts" => contact_group_contact_params
       }) do
    contact_group_params =
      Enum.into(contact_group_params, %{
        "club_id" => contact_group_form.contact_group.club_id
      })

    case Personal.create_contact_group(contact_group_params) do
      {:ok, contact_group} ->
        # TODO Fehlerprüfung
        result =
          contact_group_contact_params
          |> Map.values()
          |> Enum.map(fn contact_group_contact ->
            Enum.into(contact_group_contact, %{
              "contact_group_id" => contact_group.id
            })
          end)
          |> Enum.map(fn contact -> contact |> Personal.create_contact_group_contact() end)

        # TODO: Fehlerbehandlung. Idee Meldungen konkatinieren und auf Formular darstellen
        {:noreply,
         socket
         |> put_flash(:info, "Kontaktgruppe erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(
           socket
           |> put_flash(:error, "Beim Anlegen der Kontaktgruppe ist ein Fehler aufgetreten!"),
           form: to_form(changeset)
         )}
    end
  end
end
