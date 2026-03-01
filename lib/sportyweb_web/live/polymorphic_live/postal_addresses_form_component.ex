defmodule SportywebWeb.PolymorphicLive.PostalAddressesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.PostalAddress

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <.header level="2" class="col-span-12 md:col-span-12">
      Straßenadressen
    </.header>
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={postal_address} field={@form[:postal_addresses]}>
          <.element_index_field
            :if={PostalAddress.is_form_with_multiples?(@form.id)}
            form_id={@form.id}
            sort_param={PostalAddress.get_changeset_sort_param()}
            element={postal_address}
          />
          <div class="col-span-12 md:col-span-12">
            <.input field={postal_address[:type]} type="select" label="Art" options={PostalAddress.get_valid_types()} />
          </div>
          <div class="col-span-12 md:col-span-8">
            <.input field={postal_address[:street]} type="text" label="Straße" />
          </div>

          <div class="col-span-12 md:col-span-3">
            <.input field={postal_address[:street_number]} type="text" label="Hausnummer" />
          </div>

          <.element_delete_button
            :if={PostalAddress.is_form_with_multiples?(@form.id)}
            form_id={@form.id}
            drop_param={PostalAddress.get_changeset_drop_param()}
            class="col-span-12 md:col-span-1 mt-9"
            element={postal_address}
          />

          <div class="col-span-12">
            <.input
              field={postal_address[:street_additional_information]}
              type="text"
              label="Anschrift - Zusatzinformationen (optional)"
            />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={postal_address[:zipcode]} type="text" label="Postleitzahl" />
          </div>

          <div class="col-span-12 md:col-span-8">
            <.input field={postal_address[:city]} type="text" label="Stadt" />
          </div>

          <div class="col-span-12">
            <.input
              field={postal_address[:country]}
              type="select"
              label="Land"
              options={PostalAddress.get_valid_countries()}
              prompt="Bitte auswählen"
            />
          </div>
        </.inputs_for>
        <.element_add_button
          :if={PostalAddress.is_form_with_multiples?(@form.id)}
          form_id={@form.id}
          sort_param={PostalAddress.get_changeset_sort_param()}
          class="col-span-12"
        />
      </.input_grid>
    </div>
    """
  end
end
