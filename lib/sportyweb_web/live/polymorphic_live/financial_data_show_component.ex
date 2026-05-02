defmodule SportywebWeb.PolymorphicLive.FinancialDataShowComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Directory

  attr :financial_data, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@financial_data) do %>
      <div class="divide-y divide-zinc-100">
        <%= for financial_data_single <- @financial_data do %>
          <div class="py-4 first:pt-0 last:pb-0">
            <ul>
              <li>
                Zahlungsart: {get_key_for_value(
                  FinancialData.get_valid_types(),
                  financial_data_single.type
                )}
              </li>
              <%= if financial_data_single.type == "direct_debit" do %>
                <li>
                  Kontoinhaber: {format_string_field(
                    financial_data_single.direct_debit_account_holder
                  )}
                </li>
                <li>IBAN: {format_string_field(financial_data_single.direct_debit_iban)}</li>
                <%= if Directory.get_institute(financial_data_single.direct_debit_iban) do %>
                  <li>
                    BIC: {format_string_field(
                      Directory.get_institute(financial_data_single.direct_debit_iban).bic
                    )}
                  </li>
                  <li>
                    Name: {format_string_field(
                      Directory.get_institute(financial_data_single.direct_debit_iban).name
                    )}
                  </li>
                <% else %>
                  Zur IBAN konnte keine BIC und kein Name ermittelt werden!
                <% end %>
              <% else %>
                <li>
                  Rechnungsempfänger: {format_string_field(financial_data_single.invoice_recipient)}
                </li>
                <li>
                  Zusatzinformationen: {format_string_field(
                    financial_data_single.invoice_additional_information
                  )}
                </li>
              <% end %>
            </ul>
          </div>
        <% end %>
      </div>
    <% else %>
      -
    <% end %>
    """
  end
end
