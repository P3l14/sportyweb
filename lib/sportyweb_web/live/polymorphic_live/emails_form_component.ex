defmodule SportywebWeb.PolymorphicLive.EmailsFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.Email

  attr :form, :map, required: true
  attr :allow_multiple, :boolean, required: false, default: false

  def render(assigns) do
    ~H"""
    <%!-- <h2 class="text-xl/7 font-semibold col-span-12 md:col-span-12">EMailadressen</h2> --%>

    <.header level="2" class="col-span-12 md:col-span-12">
      E-Mail-Adressen <.errors_for_lists list_field={@form[:emails]} />
    </.header>

    <%!-- <h2 class="col-span-12 md:col-span-12" >EMailadressen</h2> --%>
    <.inputs_for :let={email} field={@form[:emails]}>
      <.element_index_field
        :if={@allow_multiple}
        form_name={@form.name}
        sort_param={Email.get_changeset_sort_param()}
        element={email}
      />
      <div class="col-span-12 md:col-span-7">
        <.input field={email[:address]} type="text" label="E-Mail (optional)" />
      </div>

      <div class="col-span-12 md:col-span-4">
        <.input field={email[:type]} type="select" label="Art" options={Email.get_valid_types()} />
      </div>
      <.element_delete_button
        :if={@allow_multiple}
        form_name={@form.name}
        drop_param={Email.get_changeset_drop_param()}
        class="col-span-12 md:col-span-1 mt-9"
        element={email}
      />
    </.inputs_for>
    <.element_add_button
      :if={@allow_multiple}
      form_name={@form.name}
      sort_param={Email.get_changeset_sort_param()}
      class="col-span-12"
    />
    """
  end
end
