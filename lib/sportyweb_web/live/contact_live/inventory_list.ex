defmodule SportywebWeb.ContactLive.InventoryList do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
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
                field={@form[:type]}
                type="select"
                label="im Format"
                options={InventoryListForm.get_valid_types()}
              />
            </div>
          </.input_grid>
        </.input_grids>
        <:actions>
          <div>
            <.button type="submit" phx-disable-with="Suchen...">Bestandsmeldung erstellen</.button>
          </div>
        </:actions>
      </.simple_form>
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
      Organization.get_club!(id)

    inventory_list_form = %InventoryListForm{
      year: Date.utc_today().year
    }

    {:noreply,
     socket
     |> assign(:page_title, "Bestandserhebung")
     |> assign(:inventory_list_form, inventory_list_form)
     |> assign(:form, to_form(InventoryListForm.changeset(inventory_list_form)))
     |> assign(:club_navigation_current_item, :members_inventory)
     |> assign(:club, club)}
  end

  @impl true
  def handle_event("validate", %{"inventory_list_form" => inventory_list_form}, socket) do
    changeset =
      InventoryListForm.changeset(socket.assigns.inventory_list_form, inventory_list_form)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("create", %{"inventory_list_form" => inventory_list_form}, socket) do
    changeset =
      InventoryListForm.changeset(socket.assigns.inventory_list_form, inventory_list_form)

    if changeset.valid? do
      inventory_list_parameters = Ecto.Changeset.apply_changes(changeset)

      {:noreply,
       socket
       |> put_flash(:info, "Starte Download")
       |> redirect(
         to:
           ~p"/clubs/#{socket.assigns.club}/members/inventory_list/#{inventory_list_parameters.year}"
       )}
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
