defmodule SportywebWeb.ContactLive.ContactRoleShowComponent do
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Personal.ContactRoleRelation
  import SportywebWeb.CommonHelper
  use SportywebWeb, :html

  attr :contact_roles, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@contact_roles) do %>
      <div class="divide-y divide-zinc-100">
        <div class="py-4 first:pt-0 last:pb-0">
          <ul>
            <%= for contact_role <- @contact_roles do %>
              <li>
                {render_role_name(contact_role)}<.icon
                  :if={ContactRole.membership_role?(contact_role.name)}
                  name="hero-check-badge"
                  class="ml-1 inline-block w-[20px] text-green-800"
                /> {render_period(
                  contact_role.valid_from,
                  contact_role.valid_until
                )}
              </li>
              <ul :if={Enum.any?(contact_role.contact_role_relations)} class="ml-5">
                <li :for={contact_role_relation <- contact_role.contact_role_relations}>
                  für
                  <.link_to target={ContactRoleRelation.get_target(contact_role_relation)} /> {render_period(
                    contact_role_relation.valid_from,
                    contact_role.valid_until
                  )}
                </li>
              </ul>
            <% end %>
          </ul>
        </div>
      </div>
    <% else %>
      -
    <% end %>
    """
  end

  defp render_period(valid_from, valid_until) do
    from_date = format_date_field_dmy(valid_from)

    if is_nil(valid_until) do
      from_date
    else
      "#{from_date} - #{format_date_field_dmy(valid_until)}"
    end
  end

  defp render_role_name(%ContactRole{} = contact_role) do
    role_name =
      get_key_for_value(
        ContactRole.get_valid_names(),
        contact_role.name
      )

    if ContactRole.get_role_relation_entry(contact_role.name)[:custom_input] do
      "#{role_name}: #{format_string_field(contact_role.custom_name)}"
    else
      role_name
    end
  end
end
