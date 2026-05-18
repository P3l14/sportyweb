defmodule SportywebWeb.ContactLive.ContactRoleRelationFormComponent do
  alias Sportyweb.Personal
  alias Sportyweb.Personal.ContactRoleRelation
  alias Sportyweb.Personal.ContactRole
  alias Sportyweb.Organization

  use SportywebWeb, :html

  attr :form, :map, required: true
  attr :role_name, :string, required: true
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
      <.realation_input
        role_name={@role_name}
        role_relation_type={ContactRole.get_role_relation_type(@role_name)}
        contact_role_relation={contact_role_relation}
        role_text={@role_text}
        club_id={@club_id}
      />

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

  attr :role_name, :string, required: true
  attr :role_relation_type, :atom, required: true
  attr :contact_role_relation, Phoenix.HTML.Form, required: true
  attr :role_text, :string, required: true
  attr :club_id, :string, required: true

  defp realation_input(assigns) do
    assigns |> assign_field_and_options_by_role |> render_relation_input()
  end

  attr :role_text, :string, required: true
  attr :field, Phoenix.HTML.FormField, required: true
  attr :options, :list, required: true

  defp render_relation_input(assigns) do
    ~H"""
    <div class="col-span-12 md:col-span-5 ml-10">
      <.input
        field={@field}
        type="select"
        label={@role_text}
        options={@options}
        prompt="Bitte auswählen"
      />
    </div>
    """
  end

  defp assign_field_and_options_by_role(
         %{contact_role_relation: contact_role_relation, club_id: club_id} = assigns
       ) do
    map =
      case assigns do
        %{role_name: "legal guardian"} ->
          contacts =
            Personal.list_underage_contacts_for_contact_role_reltation_to_legal_gurdian_selection(
              club_id
            )

          %{
            field: contact_role_relation[:contact_id],
            options:
              contacts
              |> to_name_id_key_word_list()
          }

        %{role_relation_type: :contact} ->
          contacts = Personal.list_contacts(club_id)

          %{
            field: contact_role_relation[:contact_id],
            options: contacts |> to_name_id_key_word_list()
          }

        %{role_relation_type: :department} ->
          departments = Organization.list_departments(club_id)

          %{
            field: contact_role_relation[:department_id],
            options: departments |> to_name_id_key_word_list()
          }

        %{role_relation_type: :group} ->
          groups = Organization.list_all_groups_for_club(club_id)

          %{
            field: contact_role_relation[:group_id],
            options:
              groups
              |> Enum.map(fn group ->
                [key: "#{group.department.name}: #{group.name}", value: group.id]
              end)
          }

        _ ->
          %{}
      end

    assigns
    |> assign(field: map.field)
    |> assign(options: map.options)
  end

  defp to_name_id_key_word_list(list) do
    list |> Enum.map(fn item -> [key: item.name, value: item.id] end)
  end
end
