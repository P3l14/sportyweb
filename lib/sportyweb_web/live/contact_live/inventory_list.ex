defmodule SportywebWeb.ContactLive.InventoryList do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias SportywebWeb.ContactLive.InventoryList.InventoryListForm

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>

    <.card>
      <.simple_form for={@form} phx-submit="create" phx-change="validate" target="_blank">
        <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:year]} type="number" label="Für das Jahr" />
            </div>
            <div class="col-span-12 md:col-span-2">
              <.input
                field={@form[:format]}
                type="select"
                label="im Format"
                options={InventoryListForm.get_valid_formats()}
              />
            </div>
          </.input_grid>
        </.input_grids>
      </.simple_form>
      <.link
        href={
          ~p"/clubs/#{@club}/members/inventory_list/#{@form[:year].value}/#{@form[:format].value}"
        }
        download
      >
        <div :if={Enum.any?(@error_messages)} class="mt-5">
          <.header level="2">
            Fehler
          </.header>
          <ol class="list-disc ml-5">
            <li :for={error_message <- @error_messages}>
              {error_message}
            </li>
          </ol>
        </div>
        <.button :if={@show_download_button} class="mt-10" type="clear">
          Bestandsmeldung erstellen
        </.button>
      </.link>
    </.card>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"club_id" => id}, _, socket) do
    club =
      Organization.get_club!(id, :departments)

    inventory_list_form = %InventoryListForm{
      year: Date.utc_today().year,
      format: "xml"
    }

    {:noreply,
     socket
     |> assign(:page_title, "Bestandserhebung")
     |> assign_errors_and_button_info(club, inventory_list_form.year, inventory_list_form.format)
     |> assign(:inventory_list_form, inventory_list_form)
     |> assign(:form, to_form(InventoryListForm.changeset(inventory_list_form)))
     |> assign(:club_navigation_current_item, :members_inventory)
     |> assign(:club, club)}
  end

  @impl true
  def handle_event("validate", %{"inventory_list_form" => inventory_list_form}, socket) do
    changeset =
      InventoryListForm.changeset(socket.assigns.inventory_list_form, inventory_list_form)

    socket =
      if changeset.valid? do
        socket
        |> assign_errors_and_button_info(
          socket.assigns.club,
          inventory_list_form["year"]|> String.to_integer(),
          inventory_list_form["format"]
        )
      else
        socket
      end

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp assign_errors_and_button_info(socket, club, year, format) do
    case Personal.can_create_member_inventory_list(
           club,
           year |> Date.new!(1, 1),
           format
         ) do
      {:ok} ->
        socket |> assign(:show_download_button, true)
        |> assign(:error_messages, [])

      {:error, error_messages} ->
        socket
        |> assign(:show_download_button, false)
        |> assign(:error_messages, error_messages)
    end
  end
end
