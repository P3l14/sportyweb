defmodule SportywebWeb.ContactLive.Search do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>

    <.card>
      <search>
        <.header level="2" class="col-span-12 md:col-span-12">
          Suchkriterien
        </.header>
        <.simple_form :let={form} for={@form} as={:search} phx-submit="search" phx-change="validate">
          <.input_grids>
            <SportywebWeb.ContactLive.FormComponent.contact_name_data_grid
              form={form}
              contact_form_type={:full}
            />
          </.input_grids>
          <:actions>
            <div>
              <.button type="submit" phx-disable-with="Suchen...">Suchen</.button>
              <.button type="reset" phx-click="reset">Filter zurücksetzen</.button>
            </div>
          </:actions>
        </.simple_form>
      </search>
    </.card>
    <.card class="mt-5">
      <.header level="2" class="col-span-12 md:col-span-12">
        Suchergebnisse
      </.header>
      <%= if Enum.any?(@streams.contacts.inserts) do %>
        <p>Es wurden {@hits} Kontakte gefunden</p>
        <SportywebWeb.ContactLive.Index.contact_table
          streams={@streams}
          live_action={@live_action}
          club={@club}
          type={:members}
        />
      <% else %>
        <p>
          Zu den Suchkriterien wurde kein Kontakt gefunden!
        </p>
      <% end %>
    </.card>

    <div :if={@live_action == :index_member} class="mt-4 flex align-middle">
      <.icon name="hero-check-badge" class="mr-1 inline-block w-[20px] text-green-800" /> Mitglied
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_search)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :search, %{"club_id" => club_id}) do
    club =
      Organization.get_club!(club_id,
        contacts: [:contracts, :contact_roles],
        departments: [:groups]
      )

    contacts = []
    search = %Contact{}

    socket
    |> assign(:page_title, "Kontaktsuche")
    |> assign(:club_navigation_current_item, :contact_search)
    |> assign(:club, club)
    |> assign(:search, search)
    |> assign(:form, to_form(Personal.change_short_contact(search)))
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => search},
        socket
      ) do
    search = put_in(search["club_id"], socket.assigns.club.id)

    found_contacts = Personal.search(search)

    {:noreply,
     socket
     |> assign(:hits, length(found_contacts))
     |> stream(:contacts, found_contacts, reset: true)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"search" => search},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:form, to_form(Personal.change_short_contact(socket.assigns.search, search)))}
  end

  @impl true
  def handle_event(
        "reset",
        _,
        socket
      ) do
    {:noreply,
     socket
     |> push_navigate(to: ~p"/clubs/#{socket.assigns.club.id}/contacts/search")}
  end
end
