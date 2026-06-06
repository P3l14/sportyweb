defmodule SportywebWeb.QualificationLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Qualification

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts_menue)}
  end

  @impl true
  def handle_params(%{"contact_id" => contact_id, "id" => id}, _, socket) do
    contact = Personal.get_contact!(contact_id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Qualifikation")
     |> assign(:contact, contact)
     |> assign(:club, contact.club)
     |> assign(:qualification, Personal.get_qualification!(id))}
  end

  @doc """
  Creates a description text for the qualification to show in the overview of the contact

  """
  def describe(qualification)

  def describe(%Qualification{type: "common"} = qualification) do
    "#{get_key_for_value(Qualification.get_valid_common_types(), qualification.common_type)}:  #{format_string_field(qualification.common_description)}"
  end

  def describe(%Qualification{dosb_license_type: dosb_license_type} = qualification)
      when dosb_license_type in ["coach common", "coach professional"] do
    "#{get_key_for_value(Qualification.get_valid_dosb_license_types(), qualification.dosb_license_type)} #{get_key_for_value(Qualification.get_valid_dosb_license_levels(), qualification.dosb_license_level)}-Lizenz für #{format_string_field(qualification.dosb_license_coach_sport)}"
  end

  def describe(
        %Qualification{dosb_license_type: "sport instructor", dosb_license_level: "B"} =
          qualification
      ) do
    "#{get_key_for_value(Qualification.get_valid_dosb_license_types(), qualification.dosb_license_type)} #{get_key_for_value(Qualification.get_valid_dosb_license_levels(), qualification.dosb_license_level)}-Lizenz für #{get_key_for_value(Qualification.get_valid_dosb_license_sport_instructor_types(), qualification.dosb_license_sport_instructor_type)}"
  end

  def describe(%Qualification{type: "dosb license"} = qualification) do
    "#{get_key_for_value(Qualification.get_valid_dosb_license_types(), qualification.dosb_license_type)} #{get_key_for_value(Qualification.get_valid_dosb_license_levels(), qualification.dosb_license_level)}-Lizenz"
  end
end
