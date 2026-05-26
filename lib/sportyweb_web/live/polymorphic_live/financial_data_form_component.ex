defmodule SportywebWeb.PolymorphicLive.FinancialDataFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Directory

  attr :form, :map, required: true
  attr :allow_multiple, :boolean, required: false, default: false
  attr :contacts_for_different_holder_or_recipient, :list, required: false, default: []

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.header level="2" class="col-span-12 md:col-span-12">
          Zahlungsdaten <.errors_for_lists list_field={@form[:financial_data]} />
        </.header>

        <.inputs_for :let={financial_data} field={@form[:financial_data]}>
          <.element_index_field
            :if={@allow_multiple}
            form_name={@form.name}
            sort_param={FinancialData.get_changeset_sort_param()}
            element={financial_data}
          />
          <div class="col-span-12 md:col-span-11">
            <.input
              field={financial_data[:type]}
              type="select"
              label="Zahlungsart"
              options={FinancialData.get_valid_types()}
            />
          </div>

          <.element_delete_button
            :if={@allow_multiple}
            form_name={@form.name}
            drop_param={FinancialData.get_changeset_drop_param()}
            class="col-span-12 md:col-span-1 mt-9"
            element={financial_data}
          />

          <%= if financial_data[:type].value == "direct_debit" do %>
            <div class="col-span-12 md:col-span-12">
              <.input
                field={financial_data[:direct_debit_different_account_holder_contact_id]}
                type="select"
                options={@contacts_for_different_holder_or_recipient}
                prompt="identisch mit nutzendem Kontakt - kein abweichender Bankkontoinhaber"
                label="abweichender Bankkontoinhaber"
              />
            </div>

            <.inputs_for
              :let={contact}
              :if={
                financial_data[:direct_debit_different_account_holder_contact_id].value ==
                  FinancialData.new_direct_debit_different_account_holder_value()
              }
              field={financial_data[:direct_debit_different_account_holder_contact]}
            >
              <div class="col-span-12 md:col-span-12">
                <.header level="3" class="col-span-12 md:col-span-12">
                  Neuer abweichender Bankkontoinhaber
                </.header>
                <SportywebWeb.ContactLive.FormComponent.contact_name_data_grid
                  form={contact}
                  contact_form_type={:other}
                />
              </div>
              <input type="hidden" name={"#{contact.name}[club_id]"} value={@form[:club_id].value} />
              <input
                type="hidden"
                name={"#{contact.name}[contact_roles][0][name]"}
                value="debit account holder"
              />
              <input
                type="hidden"
                name={"#{contact.name}[contact_roles][0][valid_from]"}
                value={Date.utc_today()}
              />

              <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render
                form={contact}
                allow_multiple={true}
              >
                <:additional_address_actions>
                  <.button
                    type="button"
                    name="copy_contact_address_to"
                    value={"financial_data/#{financial_data.index}/direct_debit_different_account_holder_contact/postal_addresses"}
                    class="col-span-12 md:col-span-12"
                    phx-click={JS.dispatch("change")}
                  >
                    Adresse aus Kontakt übernehmen
                  </.button>
                </:additional_address_actions>
              </SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render>
            </.inputs_for>

            <div class="col-span-12 md:col-span-12">
              <.input field={financial_data[:direct_debit_iban]} type="text" label="IBAN" />
            </div>

            <div class="col-span-6">
              <.input
                field={financial_data[:direct_debit_bic]}
                type="text"
                label="BIC (nur zur Anzeige)"
                readonly
                class="read-only:bg-gray-100 read-only:text-gray-500 read-only:border-gray-200 cursor: not-allowed"
              />
            </div>

            <div class="col-span-6">
              <.input
                field={financial_data[:direct_debit_institute]}
                type="text"
                label="Name des Instituts (nur zur Anzeige)"
                readonly
                class="read-only:bg-gray-100 read-only:text-gray-500 read-only:border-gray-200 cursor: not-allowed"
              />
            </div>
          <% end %>

          <%= if financial_data[:type].value == "invoice" do %>
            <div class="col-span-12 md:col-span-12">
              <.input
                field={financial_data[:invoice_different_recipient_contact_id]}
                type="select"
                options={@contacts_for_different_holder_or_recipient}
                prompt="identisch mit nutzendem Kontakt - kein abweichender Rechnungsempfänger"
                label="abweichender Rechnungsempfänger"
              />
            </div>

            <.inputs_for
              :let={contact}
              :if={
                financial_data[:invoice_different_recipient_contact_id].value ==
                  FinancialData.new_invoice_different_recipient_value()
              }
              field={financial_data[:invoice_different_recipient_contact]}
            >
              <div class="col-span-12 md:col-span-12">
                <.header level="3" class="col-span-12 md:col-span-12">
                  Neuer abweichender Rechnungsempfänger
                </.header>
                <SportywebWeb.ContactLive.FormComponent.contact_name_data_grid
                  form={contact}
                  contact_form_type={:other}
                />
              </div>
              <input type="hidden" name={"#{contact.name}[club_id]"} value={@form[:club_id].value} />
              <input
                type="hidden"
                name={"#{contact.name}[contact_roles][0][name]"}
                value="invoice recipient"
              />
              <input
                type="hidden"
                name={"#{contact.name}[contact_roles][0][valid_from]"}
                value={Date.utc_today()}
              />

              <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render
                form={contact}
                allow_multiple={true}
              >
                <:additional_address_actions>
                  <.button
                    type="button"
                    name="copy_contact_address_to"
                    value={"financial_data/#{financial_data.index}/invoice_different_recipient_contact/postal_addresses"}
                    class="col-span-12 md:col-span-12"
                    phx-click={JS.dispatch("change")}
                  >
                    Adresse aus Kontakt übernehmen
                  </.button>
                </:additional_address_actions>
              </SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render>
            </.inputs_for>

            <div class="col-span-12">
              <.input
                field={financial_data[:invoice_additional_information]}
                type="textarea"
                label="Zusatzinformationen (optional)"
              />
            </div>
          <% end %>
        </.inputs_for>
        <.element_add_button
          :if={@allow_multiple}
          form_name={@form.name}
          sort_param={FinancialData.get_changeset_sort_param()}
          class="col-span-12"
        />
      </.input_grid>
    </div>
    """
  end

  @doc """

  Adds necessary structs to the socket to activate the iban validation and bank proposal of the component.
  This function can only be called after the form has been assigned to the socket so that the form name can be derived.


  """
  def setup_validation_and_proposal_event_hook(
        %{assigns: %{form: %{name: form_name}}} = socket,
        assign_form_function,
        intermediate_financial_darta_holding_form_name \\ nil
      )
      when is_function(assign_form_function, 2) do
    socket
    |> Phoenix.LiveView.Lifecycle.attach_hook(
      :iban_check_and_proposal,
      :handle_event,
      fn
        "validate",
        %{
          ^form_name => params,
          "_target" => [^form_name, "financial_data", index, "direct_debit_iban"]
        },
        %{assigns: %{assign_form_function: _assign_form_function}} = socket ->
          handle_event_iban_input(params, index, socket)

        "validate",
        %{
          ^form_name => params,
          "_target" => [^form_name, _, "financial_data", index, "direct_debit_iban"]
        },
        %{assigns: %{assign_form_function: _assign_form_function}} = socket ->
          handle_event_iban_input(
            params,
            index,
            socket,
            intermediate_financial_darta_holding_form_name
          )

        _event, _params, socket ->
          {:cont, socket}
      end
    )
    |> assign(:assign_form_function, assign_form_function)
  end

  def handle_event_iban_input(
        params,
        index,
        %{assigns: %{assign_form_function: assign_form_function}} = socket,
        intermediate_financial_darta_holding_form_name \\ nil
      ) do
    iban =
      if is_nil(intermediate_financial_darta_holding_form_name) do
        get_in(params, ["financial_data", index, "direct_debit_iban"])
      else
        get_in(params, [
          intermediate_financial_darta_holding_form_name,
          "financial_data",
          index,
          "direct_debit_iban"
        ])
      end

    if Directory.can_propose_institute?(iban) do
      proposed_institute = Directory.get_institute(iban)

      debit_institute_access_path = ["financial_data", index, "direct_debit_institute"]

      debit_institute_access_path =
        if intermediate_financial_darta_holding_form_name do
          [intermediate_financial_darta_holding_form_name | debit_institute_access_path]
        else
          debit_institute_access_path
        end

      debit_bic_access_path = ["financial_data", index, "direct_debit_bic"]

      debit_bic_access_path =
        if intermediate_financial_darta_holding_form_name do
          [intermediate_financial_darta_holding_form_name | debit_bic_access_path]
        else
          debit_bic_access_path
        end

      params =
        if proposed_institute do
          params
          |> put_in(
            debit_institute_access_path,
            proposed_institute.name
          )
          |> put_in(
            debit_bic_access_path,
            proposed_institute.bic
          )
        else
          institut = get_in(params, ["financial_data", index, "direct_debit_institute"])
          bic = get_in(params, ["financial_data", index, "direct_debit_bic"])

          if institut != "" or bic != "" do
            params
            |> put_in(
              debit_institute_access_path,
              "Zur IBAN konnte kein Name ermittelt werden!"
            )
            |> put_in(
              debit_bic_access_path,
              "Zur IBAN konnte keine BIC ermittelt werden!"
            )
          else
            params
          end
        end

      {:halt,
       socket
       |> assign_form_function.(params)}
    else
      {:halt,
       socket
       |> assign_form_function.(params)}
    end
  end
end
