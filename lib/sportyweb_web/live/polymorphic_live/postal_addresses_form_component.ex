defmodule SportywebWeb.PolymorphicLive.PostalAddressesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.PostalAddress
  alias Sportyweb.Directory

  attr :form, :map, required: true
  attr :allow_multiple, :boolean, required: false, default: false
  attr :zipcode_proposals, :list, required: false, default: []
  attr :street_proposals, :list, required: false, default: []

  slot :additional_address_actions

  def render(assigns) do
    ~H"""
    <.header level="2" class="col-span-12 md:col-span-12">
      Adressen <.errors_for_lists list_field={@form[:postal_addresses]} />
    </.header>
    {render_slot(@additional_address_actions)}
    <datalist :if={@zipcode_proposals} id="zipcode_proposals">
      <option :for={zipcode_proposal <- @zipcode_proposals} value={zipcode_proposal |> hd}>
        {Enum.join(zipcode_proposal, " ")}
      </option>
    </datalist>
    <datalist :if={@street_proposals} id="street_proposals">
      <option :for={street_proposal <- @street_proposals} value={street_proposal}>
        {street_proposal}
      </option>
    </datalist>
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={postal_address} field={@form[:postal_addresses]}>
          <.element_index_field
            :if={@allow_multiple}
            form_name={@form.name}
            sort_param={PostalAddress.get_changeset_sort_param()}
            element={postal_address}
          />
          <div class="col-span-12 md:col-span-11">
            <.input
              field={postal_address[:type]}
              type="select"
              label="Art"
              options={PostalAddress.get_valid_types()}
            />
          </div>

          <.element_delete_button
            :if={@allow_multiple}
            form_name={@form.name}
            drop_param={PostalAddress.get_changeset_drop_param()}
            class="col-span-12 md:col-span-1 mt-9"
            element={postal_address}
          />

          <div class="col-span-12">
            <.input
              field={postal_address[:country]}
              type="select"
              label="Land"
              options={PostalAddress.get_valid_countries()}
              prompt="Bitte auswählen"
            />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input
              field={postal_address[:zipcode]}
              type="text"
              label="Postleitzahl"
              list="zipcode_proposals"
            />
          </div>

          <div class="col-span-12 md:col-span-8">
            <.input field={postal_address[:city]} type="text" label="Ort" />
          </div>

          <div class="col-span-12 md:col-span-8">
            <.input
              field={postal_address[:street]}
              type="text"
              label="Straße"
              list="street_proposals"
            />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={postal_address[:street_number]} type="text" label="Hausnummer" />
          </div>

          <div class="col-span-12">
            <.input
              field={postal_address[:street_additional_information]}
              type="text"
              label="Anschrift - Zusatzinformationen (optional)"
            />
          </div>
        </.inputs_for>
        <.element_add_button
          :if={@allow_multiple}
          form_name={@form.name}
          sort_param={PostalAddress.get_changeset_sort_param()}
          class="col-span-12"
        />
      </.input_grid>
    </div>
    """
  end

  @doc """

  Adds necessary structs to the socket to activate the city and street proposal of the component.
  This function can only be called after the form has been assigned to the socket so that the form name can be derived.


  """
  def setup_validation_and_proposal_event_hook(
        %{assigns: %{form: %{name: form_name}}} = socket,
        assign_form_function,
        intermediate_address_holding_form_name \\ nil
      )
      when is_function(assign_form_function, 2) do
    socket
    |> Phoenix.LiveView.Lifecycle.attach_hook(
      :zipcode_check_and_proposal,
      :handle_event,
      fn
        "validate",
        %{
          ^form_name => params,
          "_target" => [^form_name, "postal_addresses", index, "zipcode"]
        },
        %{assigns: %{assign_form_function: _assign_form_function}} = socket ->
          handle_event_zipcode_input(params, index, socket)

        "validate",
        %{
          ^form_name => params,
          "_target" => [^form_name, _, "postal_addresses", index, "zipcode"]
        },
        %{assigns: %{assign_form_function: _assign_form_function}} = socket ->
          handle_event_zipcode_input(
            params,
            index,
            socket,
            intermediate_address_holding_form_name
          )

        _event, _params, socket ->
          {:cont, socket}
      end
    )
    |> assign(:assign_form_function, assign_form_function)
    |> assign(zipcode_proposals: [])
    |> assign(street_proposals: [])
  end

  def handle_event_zipcode_input(
        params,
        index,
        %{assigns: %{assign_form_function: assign_form_function}} = socket,
        intermediate_address_holding_form_name \\ nil
      ) do
    postal_address_access_path = ["postal_addresses", index]

    postal_address_access_path =
      if intermediate_address_holding_form_name do
        [intermediate_address_holding_form_name | postal_address_access_path]
      else
        postal_address_access_path
      end

    postal_address = get_in(params, postal_address_access_path)

    %{"country" => country, "zipcode" => zipcode} = postal_address

    if String.length(zipcode) == 2 do
      zipcodes = Directory.get_zipcodes(country, zipcode)

      {:halt,
       socket
       |> assign(zipcode_proposals: zipcodes)
       |> assign_form_function.(params)}
    else
      proposed_city =
        if socket.assigns[:zipcode_proposals] do
          find_city(socket.assigns[:zipcode_proposals], zipcode)
        else
          nil
        end

      params =
        if is_nil(proposed_city) do
          params
        else
          if is_nil(intermediate_address_holding_form_name) do
            put_in(params, ["postal_addresses", index, "city"], proposed_city)
          else
            put_in(
              params,
              [intermediate_address_holding_form_name, "postal_addresses", index, "city"],
              proposed_city
            )
          end
        end

      streets = Directory.get_streets(country, zipcode)

      {:halt,
       socket
       |> assign(street_proposals: streets)
       |> assign_form_function.(params)}
    end
  end

  defp find_city(zipcode_proposals, zipcode) do
    zipcode_proposals
    |> Enum.find_value(fn entry ->
      if entry |> hd == zipcode, do: entry |> Enum.at(1)
    end)
  end
end
