defmodule SportywebWeb.ContactLive.ContactRoleFormComponent do
  alias Sportyweb.Personal.ContactRole
  use SportywebWeb, :html

  attr :form, :map, required: true
  attr :allow_multiple, :boolean, required: false, default: false

  def render(assigns) do
    ~H"""
    <.header level="2" class="col-span-12 md:col-span-12">
      Rollen
    </.header>

    <.inputs_for :let={contact_role} field={@form[:contact_roles]}>
      <.element_index_field
        :if={@allow_multiple}
        form_name={@form.name}
        sort_param={ContactRole.get_changeset_sort_param()}
        element={contact_role}
      />
      <div class="col-span-12 md:col-span-5">
        <.input
          field={contact_role[:name]}
          type="select"
          label="Rolle"
          options={ContactRole.get_valid_names()}
          prompt="Bitte auswählen"
        />
      </div>

      <div class="col-span-12 md:col-span-3">
        <.input field={contact_role[:valid_from]} type="date" label="Gültig seit" />
      </div>

      <div class="col-span-12 md:col-span-3">
        <.input field={contact_role[:valid_until]} type="date" label="Gültig bis (optional)" />
      </div>

      <.element_delete_button
        :if={@allow_multiple}
        form_name={@form.name}
        drop_param={ContactRole.get_changeset_drop_param()}
        class="col-span-12 md:col-span-1 mt-9"
        element={contact_role}
      />

      <SportywebWeb.ContactLive.ContactRoleRelationFormComponent.render
        :if={contact_role[:name].value == "legal guardian"}
        form={contact_role}
        role_text="für"
        club_id={@form[:club_id].value}
        allow_multiple={true}
      />
    </.inputs_for>

    <.element_add_button
      :if={@allow_multiple}
      form_name={@form.name}
      sort_param={ContactRole.get_changeset_sort_param()}
      class="col-span-12"
    />
    """
  end
end
