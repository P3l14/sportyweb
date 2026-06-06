defmodule SportywebWeb.QualificationLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Qualification

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
          id="qualification-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-12">
                <.input
                  field={@form[:type]}
                  type="select"
                  label="Art"
                  options={Qualification.get_valid_types()}
                  prompt="Bitte auswählen"
                />
              </div>
              <%= case @form[:type].value do %>
                <% "dosb license" -> %>
                  <div class="col-span-12 md:col-span-4">
                    <.input
                      field={@form[:dosb_license_type]}
                      type="select"
                      label="Lizenzart"
                      options={Qualification.get_valid_dosb_license_types()}
                      prompt="Bitte auswählen"
                    />
                  </div>
                  <div class="col-span-12 md:col-span-3">
                    <.input
                      field={@form[:dosb_license_level]}
                      type="select"
                      label="Lizenzstufe"
                      options={
                        Qualification.get_valid_dosb_license_levels(@form[:dosb_license_type].value)
                      }
                      prompt="Bitte auswählen"
                    />
                  </div>
                  <div
                    :if={
                      @form[:dosb_license_type].value == "sport instructor" and
                        @form[:dosb_license_level].value == "B"
                    }
                    class="col-span-12 md:col-span-5"
                  >
                    <.input
                      field={@form[:dosb_license_sport_instructor_type]}
                      type="select"
                      label="Übungsleiter B Lizenztyp"
                      options={Qualification.get_valid_dosb_license_sport_instructor_types()}
                      prompt="Bitte auswählen"
                    />
                  </div>
                  <div
                    :if={@form[:dosb_license_type].value in ["coach common", "coach professional"]}
                    class="col-span-12 md:col-span-5"
                  >
                    <.input field={@form[:dosb_license_coach_sport]} type="text" label="Sportart" />
                  </div>
                  <div class="col-span-12 md:col-span-6">
                    <.input field={@form[:dosb_license_number]} type="text" label="Lizenznummer" />
                  </div>
                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:dosb_license_number_sports_association]}
                      type="text"
                      label="Verbandslizenznummer (optional)"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={@form[:dosb_first_issuance]}
                      type="date"
                      label="Erstaustellungsdatum"
                    />
                  </div>
                  <div class="col-span-12 md:col-span-6">
                    <.input field={@form[:dosb_valid_until]} type="date" label="Gültig bis" />
                  </div>
                <% "common" -> %>
                  <div class="col-span-12 md:col-span-8">
                    <.input
                      field={@form[:common_type]}
                      type="select"
                      label="Allgemeine Qualifiaktionsart"
                      options={Qualification.get_valid_common_types()}
                      prompt="Bitte auswählen"
                    />
                  </div>
                  <div class="col-span-12 md:col-span-4">
                    <.input field={@form[:common_issuance]} type="date" label="Erteilungsdatum" />
                  </div>
                  <div class="col-span-12 md:col-span-12">
                    <.input field={@form[:common_description]} type="text" label="Besschreibung" />
                  </div>
                <% _ -> %>
              <% end %>
            </.input_grid>
          </.input_grids>
          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@qualification.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @qualification.id})}
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
  def update(%{qualification: qualification} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Personal.change_qualification(qualification))
     end)}
  end

  @impl true
  def handle_event("validate", %{"qualification" => qualification_params}, socket) do
    changeset = Personal.change_qualification(socket.assigns.qualification, qualification_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"qualification" => qualification_params}, socket) do
    save_qualification(socket, socket.assigns.action, qualification_params)
  end

  defp save_qualification(socket, :edit, qualification_params) do
    case Personal.update_qualification(socket.assigns.qualification, qualification_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Qualifikation erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_qualification(socket, :new, qualification_params) do
    qualification_params = put_in(qualification_params, ["contact_id"], socket.assigns.contact.id)

    case Personal.create_qualification(qualification_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Qualifikation erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
