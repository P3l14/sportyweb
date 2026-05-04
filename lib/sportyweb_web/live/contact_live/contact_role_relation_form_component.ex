defmodule SportywebWeb.ContactLive.ContactRoleRelationFormComponent do
  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactRoleRelation

  use SportywebWeb, :html

  attr :form, :map, required: true
  attr :header, :string, required: false, default: nil
  attr :role_text, :string, required: true
  attr :club_id, :string, required: true
  attr :allow_multiple, :boolean, required: false, default: false

  def render(assigns) do
    ~H"""
    <.header :if={@header} level="5" class="col-span-12 md:col-span-12 ml-10">
      {@header}
    </.header>

    <.inputs_for :let={contact_role_relation} field={@form[:contact_role_relations]}>
      <.element_index_field
        :if={@allow_multiple}
        form_name={@form.name}
        sort_param={ContactRoleRelation.get_changeset_sort_param()}
        element={contact_role_relation}
      />
      <div class="col-span-12 md:col-span-5 ml-10">
        <.input
          field={contact_role_relation[:contact_id]}
          type="select"
          label={@role_text}
          options={
            Personal.list_underage_contacts_for_contact_role_reltation_to_legal_gurdian_selection(
              @club_id
            )
            |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)
          }
          prompt="Bitte auswählen"
        />
      </div>

      <div class="col-span-12 md:col-span-3">
        <.input field={contact_role_relation[:valid_from]} type="date" label="Gültig seit" />
      </div>

      <div class="col-span-12 md:col-span-3">
        <.input
          field={contact_role_relation[:valid_until]}
          type="date"
          label="Gültig bis (optional)"
        />
      </div>

      <.element_delete_button
        :if={@allow_multiple}
        form_name={@form.name}
        drop_param={ContactRoleRelation.get_changeset_drop_param()}
        class="col-span-12 md:col-span-1 mt-9"
        element={contact_role_relation}
      />
    </.inputs_for>

    <.element_add_button
      :if={@allow_multiple}
      form_name={@form.name}
      sort_param={ContactRoleRelation.get_changeset_sort_param()}
      class="col-span-12 ml-10"
    />
    """
  end
end
