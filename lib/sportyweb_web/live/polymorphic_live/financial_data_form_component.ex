defmodule SportywebWeb.PolymorphicLive.FinancialDataFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Directory

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.header level="2" class="col-span-12 md:col-span-12">
          Zahlungsdaten <.errors_for_lists list_field={@form[:financial_data]} />
        </.header>

        <.inputs_for :let={financial_data} field={@form[:financial_data]}>
          <div class="col-span-12">
            <.input
              field={financial_data[:type]}
              type="select"
              label="Zahlungsart"
              options={FinancialData.get_valid_types()}
            />
          </div>

          <%= if financial_data[:type].value == "direct_debit" do %>
            <div class="col-span-12 md:col-span-7">
              <.input
                field={financial_data[:direct_debit_account_holder]}
                type="text"
                label="Kontoinhaber"
              />
            </div>

            <div class="col-span-12 md:col-span-5">
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
            <div class="col-span-12">
              <.input
                field={financial_data[:invoice_recipient]}
                type="text"
                label="Rechnungsempfänger"
              />
            </div>

            <div class="col-span-12">
              <.input
                field={financial_data[:invoice_additional_information]}
                type="textarea"
                label="Zusatzinformationen (optional)"
              />
            </div>
          <% end %>
        </.inputs_for>
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
        assign_form_function
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

        _event, _params, socket ->
          {:cont, socket}
      end
    )
    |> assign(:assign_form_function, assign_form_function)
  end

  def handle_event_iban_input(
        params,
        index,
        %{assigns: %{assign_form_function: assign_form_function}} = socket
      ) do
    iban = get_in(params, ["financial_data", index, "direct_debit_iban"])

    if Directory.can_propose_institute?(iban) do
      proposed_institute = Directory.get_institute(iban)

      params =
        if is_nil(proposed_institute) do
          institut = get_in(params, ["financial_data", index, "direct_debit_institute"])
          bic = get_in(params, ["financial_data", index, "direct_debit_bic"])

          if institut != "" or bic != "" do
            params
            |> put_in(
              ["financial_data", index, "direct_debit_institute"],
              "Zur IBAN konnte kein Name ermittelt werden!"
            )
            |> put_in(
              ["financial_data", index, "direct_debit_bic"],
              "Zur IBAN konnte keine BIC ermittelt werden!"
            )
          else
            params
          end
        else
          params
          |> put_in(
            ["financial_data", index, "direct_debit_institute"],
            proposed_institute.name
          )
          |> put_in(
            ["financial_data", index, "direct_debit_bic"],
            proposed_institute.bic
          )
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
