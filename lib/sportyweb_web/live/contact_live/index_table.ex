defmodule SportywebWeb.ContactLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact

  attr :contacts, :list, required: true

  def render(assigns) do
    # use of SportywebWeb.ContactLive.Index.contact_table requires that a stream is passed and preloads are made on the contacts for contracts and contact_roles. Could be called after refactoring in the future
    ~H"""
    <div>
      <.table id="contacts" rows={@contacts} row_click={&JS.navigate(~p"/contacts/#{&1}")}>
        <:col :let={contact} label="Name">
          {format_string_field(contact.name)}
        </:col>
        <:col :let={contact} label="Art">
          {get_key_for_value(Contact.get_valid_types(), contact.type)}
        </:col>

        <:col :let={contact} label="Geschlecht">
          {get_key_for_value(Contact.get_valid_genders(), contact.person_gender)}
        </:col>

        <:col :let={contact} label="Geburtsdatum">
          {format_date_field_dmy(contact.person_birthday)}
        </:col>

        <:action :let={contact}>
          <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
        </:action>
      </.table>
    </div>
    """
  end
end
