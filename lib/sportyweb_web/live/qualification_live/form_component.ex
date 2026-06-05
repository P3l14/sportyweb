defmodule SportywebWeb.QualificationLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage qualification records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="qualification-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:dosb_license_type]} type="text" label="Dosb license type" />
        <.input field={@form[:dosb_license_level]} type="text" label="Dosb license level" />
        <.input field={@form[:dosb_license_number]} type="text" label="Dosb license number" />
        <.input
          field={@form[:dosb_license_number_sports_association]}
          type="text"
          label="Dosb license number sports association"
        />
        <.input field={@form[:dosb_license_coach_sport]} type="text" label="Dosb license coach sport" />
        <.input
          field={@form[:dosb_license_sport_instructor_type]}
          type="text"
          label="Dosb license sport instructor type"
        />
        <.input field={@form[:dosb_first_issuance]} type="date" label="Dosb first issuance" />
        <.input field={@form[:dosb_valid_until]} type="date" label="Dosb valid until" />
        <.input field={@form[:common_type]} type="text" label="Common type" />
        <.input field={@form[:common_description]} type="text" label="Common description" />
        <.input field={@form[:common_issuance]} type="date" label="Common issuance" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Qualification</.button>
        </:actions>
      </.simple_form>
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
      {:ok, qualification} ->
        notify_parent({:saved, qualification})

        {:noreply,
         socket
         |> put_flash(:info, "Qualification updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_qualification(socket, :new, qualification_params) do
    case Personal.create_qualification(qualification_params) do
      {:ok, qualification} ->
        notify_parent({:saved, qualification})

        {:noreply,
         socket
         |> put_flash(:info, "Qualification created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
