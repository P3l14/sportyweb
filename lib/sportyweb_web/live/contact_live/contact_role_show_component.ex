defmodule SportywebWeb.ContactLive.ContactRoleShowComponent do
  alias Sportyweb.Personal.ContactRole
  import SportywebWeb.CommonHelper
  use SportywebWeb, :html

  attr :contact_roles, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@contact_roles) do %>
      <div class="divide-y divide-zinc-100">
        <%= for contact_role <- @contact_roles do %>
          <div class="py-4 first:pt-0 last:pb-0">
            <ul>
              <li>
                {get_key_for_value(
                  ContactRole.get_valid_names(),
                  contact_role.name
                )} {render_period(contact_role.valid_from, contact_role.valid_until)}
              </li>
              <ul :if={Enum.any?(contact_role.contact_role_relations)} class="ml-5">
                <li :for={contact_role_relation <- contact_role.contact_role_relations}>
                  für {format_string_field(contact_role_relation.contact.name)} {render_period(
                    contact_role_relation.valid_from,
                    contact_role.valid_until
                  )}
                </li>
              </ul>
            </ul>
          </div>
        <% end %>
      </div>
    <% else %>
      -
    <% end %>
    """
  end

  defp render_period(valid_from, valid_until) do
    if is_nil(valid_until) do
      format_date_field_dmy(valid_from)
    else
      "#{format_date_field_dmy(valid_from)} - #{format_date_field_dmy(valid_until)}"
    end
  end
end
