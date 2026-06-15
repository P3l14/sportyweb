defmodule SportywebWeb.QualificationLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Qualification

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members_qualifications)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club =
      Organization.get_club!(club_id,
        departments: [:groups],
        contacts: [:qualifications, contracts: [:departments, :groups]]
      )

    # A member is a person with a contract. The contract must not be active.
    empty_date_default = %Qualification{
      dosb_valid_until: Date.add(Date.utc_today(), 10 * 365)
    }

    contacts =
      club.contacts
      |> Enum.filter(fn contact ->
        !Enum.empty?(contact.contracts) and
          !Enum.empty?(contact.qualifications)
      end)
      |> Enum.sort_by(
        fn contact ->
          qualification_with_recent_valid_until_date =
            Enum.min_by(
              contact.qualifications
              |> Enum.filter(fn qualification -> qualification.dosb_valid_until end),
              fn qualification ->
                qualification.dosb_valid_until
              end,
              Date,
              fn -> empty_date_default end
            )

          qualification_with_recent_valid_until_date.dosb_valid_until
        end,
        Date
      )

    socket
    |> assign(:member_inventory_year, Date.utc_today().year)
    |> assign_common_values("Mitgliederqualifikationen", club, :members_qualifications, contacts)
  end

  defp assign_common_values(socket, page_title, club, club_navigation_current_item, contacts) do
    number_of_contacts = length(contacts)

    socket
    |> assign(:page_title, page_title)
    |> assign(:club_navigation_current_item, club_navigation_current_item)
    |> assign(:type, club_navigation_current_item)
    |> assign(:club, club)
    |> assign(:contacts_present, Enum.any?(contacts))
    |> assign(:contacts_total, number_of_contacts)
    |> assign(:contacts_shown, number_of_contacts)
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event(
        "search",
        %{"search" => %{"name" => name, "qualification_type" => qualification_type}},
        socket
      ) do
    # mode =
    #   if socket.assigns.live_action == :index_member do
    #     :only_members
    #   else
    #     :only_contacts
    #   end

    filtered_contacts =
      Personal.filter_qualifications(socket.assigns.club.id, name, qualification_type)

    {:noreply,
     socket
     |> assign(:contacts_shown, length(filtered_contacts))
     |> stream(:contacts, filtered_contacts, reset: true)}
  end

  attr :streams, :map, required: true
  attr :club, Sportyweb.Organization.Club, required: true
  attr :live_action, :atom, required: true
  attr :type, :atom, required: true

  def contact_table(assigns) do
    ~H"""

    """
  end
end
