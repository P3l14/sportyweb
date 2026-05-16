defmodule SportywebWeb.PolymorphicLive.NotesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.Note

  attr :form, :map, required: true
  attr :allow_multiple, :boolean, required: false, default: false

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={note} field={@form[:notes]}>
          <.element_index_field
            :if={@allow_multiple}
            form_name={@form.name}
            sort_param={Note.get_changeset_sort_param()}
            element={note}
          />
          <div class="col-span-12 md:col-span-9">
            <.input label="Notizen (optional)" field={note[:content]} type="textarea" />
          </div>
          <.element_delete_button
            :if={@allow_multiple}
            form_name={@form.name}
            drop_param={Note.get_changeset_drop_param()}
            class="col-span-12 md:col-span-1"
            element={note}
          />
        </.inputs_for>
        <.element_add_button
          :if={@allow_multiple}
          form_name={@form.name}
          sort_param={Note.get_changeset_sort_param()}
          class="col-span-12 mt-5"
        />
      </.input_grid>
    </div>
    """
  end
end
