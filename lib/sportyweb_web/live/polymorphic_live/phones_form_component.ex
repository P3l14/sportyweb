defmodule SportywebWeb.PolymorphicLive.PhonesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.Phone

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <.header level="2" class="col-span-12 md:col-span-12">
      Telefonnummern
    </.header>

    <.inputs_for :let={phone} field={@form[:phones]}>
      <.element_index_field
        :if={Phone.is_form_with_multiples?(@form.id)}
        form_id={@form.id}
        sort_param={Phone.get_changeset_sort_param()}
        element={phone}
      />
      <div class="col-span-12 md:col-span-8">
        <.input field={phone[:number]} type="text" label="Telefon (optional)" />
      </div>

      <div class="col-span-12 md:col-span-3">
        <.input field={phone[:type]} type="select" label="Art" options={Phone.get_valid_types()} />
      </div>
      <.element_delete_button
        :if={Phone.is_form_with_multiples?(@form.id)}
        form_id={@form.id}
        drop_param={Phone.get_changeset_drop_param()}
        class="col-span-12 md:col-span-1 mt-9"
        element={phone}
      />
    </.inputs_for>
    <.element_add_button
      :if={Phone.is_form_with_multiples?(@form.id)}
      form_id={@form.id}
      sort_param={Phone.get_changeset_sort_param()}
      class="col-span-12"
    />
    """
  end
end
