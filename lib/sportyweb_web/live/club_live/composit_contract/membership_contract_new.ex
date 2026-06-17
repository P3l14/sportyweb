defmodule SportywebWeb.ClubLive.MembershipContract do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Organization
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress
  alias SportywebWeb.ClubLive.MembershipContractForm
  alias SportywebWeb.ClubLive.DepartmentSelection
  alias SportywebWeb.ClubLive.GroupSelection

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form for={@form} id="membership-form" phx-change="validate" phx-submit="save">
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-12">
                <.input
                  field={@form[:contact_id]}
                  type="select"
                  label="Kontakt"
                  options={@contact_options_for_contract}
                  prompt="Bitte auswählen"
                />
              </div>
            </.input_grid>
            <.inputs_for
              :let={contact}
              :if={@form[:contact_id].value == MembershipContractForm.new_contact_value()}
              field={@form[:contact]}
            >
              <SportywebWeb.ContactLive.FormComponent.contact_grid
                form={contact}
                render_roles={false}
                contact_form_type={:full}
                zipcode_proposals={@zipcode_proposals}
                street_proposals={@street_proposals}
                propably_duplicate_contacts={@propably_duplicate_contacts}
                contacts_for_different_holder_or_recipient={
                  @contacts_for_different_holder_or_recipient
                }
              >
                <:additional_actions_for_dupplicate_contacts :let={duplicate_contact}>
                  <.button
                    class="ml-4"
                    type="button"
                    phx-click="use_contact"
                    phx-value-contact_id={duplicate_contact.id}
                  >
                    Kontakt verwenden
                  </.button>
                </:additional_actions_for_dupplicate_contacts>
              </SportywebWeb.ContactLive.FormComponent.contact_grid>

              <.input_grid :if={Contact.underage_person?(contact[:person_birthday].value)}>
                <.header level="2" class="col-span-12 md:col-span-12">
                  Angaben zum Erziehungsberechtigten
                </.header>
                <div class="col-span-12 md:col-span-12">
                  <.input
                    field={@form[:legal_guardian_contact_id]}
                    type="select"
                    label="Erziehungsberechtigter"
                    options={@contact_options_for_legal_guardian}
                    prompt="Bitte auswählen"
                  />
                  <.input_description>
                    Bei minderjährigen Personen muss ein Erziehungsberechtigter erfasst werden.
                  </.input_description>
                </div>
              </.input_grid>
              <.inputs_for
                :let={contact}
                :if={
                  @form[:legal_guardian_contact_id].value ==
                    FinancialData.new_invoice_different_recipient_value()
                }
                field={@form[:legal_guardian_contact]}
              >
                <div class="col-span-12 md:col-span-12">
                  <.header level="3" class="col-span-12 md:col-span-12">
                    Neuer Erziehungsberechtigter
                  </.header>
                  <SportywebWeb.ContactLive.FormComponent.contact_name_data_grid
                    form={contact}
                    contact_form_type={:"legal guardian"}
                  />
                </div>
                <input type="hidden" name={"#{contact.name}[club_id]"} value={@club.id} />
                <input
                  type="hidden"
                  name={"#{contact.name}[contact_roles][0][name]"}
                  value="legal guardian"
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
                    <.input_grid>
                      <.button
                        type="button"
                        name="copy_contact_address_to"
                        value="legal_guardian_contact/postal_addresses"
                        class="col-span-12 md:col-span-12"
                        phx-click={JS.dispatch("change")}
                      >
                        Adresse aus Kontakt übernehmen
                      </.button>
                    </.input_grid>
                  </:additional_address_actions>
                </SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render>
              </.inputs_for>
            </.inputs_for>

            <.input_grid>
              <.header level="2" class="col-span-12 md:col-span-12">
                Angaben zu Familienmitgliedschaften
              </.header>
              <div class="col-span-12 md:col-span-12">
                <.input
                  field={@form[:contact_group_id]}
                  type="select"
                  label="Familien Kontaktgruppe"
                  options={@contact_group_options_for_contact}
                  prompt="Keine Familienkontaktgruppe"
                />
              </div>
            </.input_grid>
            <SportywebWeb.ContactGroupLive.FormComponent.contact_group_name_and_type
              :if={@form[:contact_group_id].value == "new"}
              form={@form}
            />

            <.input_grid>
              <.header level="2" class="col-span-12 md:col-span-12">
                Vereinsmitgliedschaftsvertrag
              </.header>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:signing_date]} type="date" label="Unterzeichnungsdatum" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Vertragsbeginn" />
              </div>

              <div class="col-span-12 md:col-span-12">
                <.input
                  field={@form[:club_fee_id]}
                  type="select"
                  label="Vereinsgebühr"
                  options={@club_fees_for_selection |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>

              <.header
                :if={@form[:department_selections].value != []}
                level="2"
                class="col-span-12 md:col-span-12"
              >
                Abteilungen
              </.header>
              <.inputs_for :let={department_selection} field={@form[:department_selections]}>
                <div class="col-span-12 md:col-span-6 mt-10">
                  <.input
                    type="checkbox"
                    field={department_selection[:checked]}
                    label={department_selection[:name].value}
                  /> <.input type="hidden" field={department_selection[:name]} />
                  <.input type="hidden" field={department_selection[:id]} />
                </div>

                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={department_selection[:fee_id]}
                    type="select"
                    label="Gebühr"
                    options={
                      @department_id_fees_map_for_selection
                      |> Map.get(department_selection[:id].value, [])
                      |> Enum.map(&{&1.name, &1.id})
                    }
                    prompt="Bitte auswählen"
                    disabled={!department_selection[:checked].value}
                  />
                </div>

                <.inputs_for :let={group_selection} field={department_selection[:group_selections]}>
                  <div class="col-span-12 md:col-span-6 mt-10 ml-10">
                    <.input
                      type="checkbox"
                      field={group_selection[:checked]}
                      label={group_selection[:name].value}
                      disabled={!department_selection[:checked].value}
                    /> <.input type="hidden" field={group_selection[:name]} />
                    <.input type="hidden" field={group_selection[:id]} />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={group_selection[:fee_id]}
                      type="select"
                      label="Gebühr"
                      options={
                        @group_id_fees_map_for_selection
                        |> Map.get(group_selection[:id].value, [])
                        |> Enum.map(&{&1.name, &1.id})
                      }
                      prompt="Bitte auswählen"
                      disabled={!group_selection[:checked].value}
                    />
                  </div>
                </.inputs_for>
              </.inputs_for>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>

              <.cancel_button navigate={~p"/clubs/#{@club}/contacts"}>Abbrechen</.cancel_button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _url, socket) do
    club = Organization.get_club!(club_id, [:contracts, departments: [:fees, groups: :fees]])

    contact = %Contact{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      financial_data: [%FinancialData{}],
      notes: [%Note{}]
    }

    contact_group = %ContactGroup{
      club_id: club.id
    }

    membership_contract_form = %MembershipContractForm{
      signing_date: Date.utc_today(),
      contact: contact,
      contact_group: contact_group,
      department_selections:
        for(
          department <- club.departments,
          do: %DepartmentSelection{
            id: department.id,
            name: department.name,
            checked: false,
            group_selections:
              for(
                group <- department.groups,
                do: %GroupSelection{
                  id: group.id,
                  name: group.name,
                  checked: false
                }
              )
          }
        )
    }

    contact_options_for_contract =
      club.id
      |> Personal.list_contract_contact_options(club)
      |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)

    contact_options_for_contract = [
      [key: "Neuen Kontakt anlegen", value: MembershipContractForm.new_contact_value()]
      | contact_options_for_contract
    ]

    contact_group_options_for_contact = [
      [key: "Neue Kontaktgruppe anlegen", value: "new"]
      | club_id
        |> Personal.list_contact_groups()
        |> Enum.map(fn contact_group -> [key: contact_group.name, value: contact_group.id] end)
    ]

    {:noreply,
     socket
     |> assign(:title, "Aufnahmeantragserfassung")
     |> assign(:contact, contact)
     |> assign(:membership_contract_form, membership_contract_form)
     |> assign_contact_options_for_legal_guardian(club.id)
     |> assign(:contact_group_options_for_contact, contact_group_options_for_contact)
     |> assign(:contact_options_for_contract, contact_options_for_contract)
     |> assign_new(:form, fn ->
       to_form(MembershipContractForm.changeset(membership_contract_form))
     end)
     |> assign(:club, club)
     |> reset_fees_for_selection()
     |> assign(:propably_duplicate_contacts, [])
     |> SportywebWeb.ContactLive.FormComponent.assign_contacts_for_different_holder_or_recipient(
       club.id
     )
     |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2,
       "contact"
     )
     |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2,
       "contact"
     )
     |> SportywebWeb.ContactLive.FormComponent.setup_contact_duplicate_check_event_hook(
       fn parameter -> parameter["membership_contract_form"]["contact"] end
     )
     |> SportywebWeb.ContactLive.FormComponent.setup_contact_copy_addresses_event_hook(
       &assign_form/2,
       ["membership_contract_form", "contact"],
       fn parameter -> parameter["membership_contract_form"] end,
       ["contact"]
     )}
  end

  defp assign_contact_options_for_legal_guardian(socket, club_id, additional_entry \\ nil) do
    contact_options_for_legal_guardian =
      club_id
      |> Personal.list_contacts_for_contact_role_legal_gurdian_selection()
      |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)

    contact_options_for_legal_guardian =
      if additional_entry do
        [
          additional_entry
          | contact_options_for_legal_guardian
        ]
      else
        contact_options_for_legal_guardian
      end

    contact_options_for_legal_guardian = [
      [
        key: "Neuen Kontakt anlegen",
        value: :new
      ]
      | contact_options_for_legal_guardian
    ]

    assign(socket, :contact_options_for_legal_guardian, contact_options_for_legal_guardian)
  end

  def assign_form(socket, membership_contract_form) do
    changeset =
      MembershipContractForm.changeset(
        socket.assigns.membership_contract_form,
        membership_contract_form
      )

    socket
    |> assign(form: to_form(changeset, action: :validate))
  end

  @impl true
  def handle_event(
        "use_contact",
        %{
          "contact_id" => _contact_id
        } = params,
        socket
      ) do
    {:noreply,
     socket
     |> assign_form(params)
     |> assign(:propably_duplicate_contacts, [])}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" =>
            [
              "membership_contract_form",
              "contact",
              "financial_data",
              "0",
              "direct_debit_different_account_holder_contact_id"
            ] = target,
          "membership_contract_form" => membership_contract_form
        } = form_parameter,
        socket
      ) do
    additional_entry_for_legal_guardian =
      case get_in(form_parameter, target) do
        "new" ->
          [
            key: "Neuen abweichenden Bankkontoinhaber verwenden",
            value: :new_direct_debit_different_account_holder_contact
          ]

        _ ->
          nil
      end

    {:noreply,
     socket
     |> assign_contact_options_for_legal_guardian(
       socket.assigns.club.id,
       additional_entry_for_legal_guardian
     )
     |> assign_form(membership_contract_form)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" =>
            [
              "membership_contract_form",
              "contact",
              "financial_data",
              "0",
              "invoice_different_recipient_contact_id"
            ] = target,
          "membership_contract_form" => membership_contract_form
        } = form_parameter,
        socket
      ) do
    additional_entry_for_legal_guardian =
      case get_in(form_parameter, target) do
        "new" ->
          [
            key: "Neuen abweichenden Rechnungsempfänger verwenden",
            value: :new_invoice_different_recipient_contact
          ]

        _ ->
          nil
      end

    {:noreply,
     socket
     |> assign_contact_options_for_legal_guardian(
       socket.assigns.club.id,
       additional_entry_for_legal_guardian
     )
     |> assign_form(membership_contract_form)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["membership_contract_form", "contact_id"],
          "membership_contract_form" => %{"contact_id" => contact_id} = membership_contract_form
        },
        socket
      ) do
    if contact_id in [MembershipContractForm.new_contact_value(), ""] do
      {:noreply,
       socket
       |> assign_form(membership_contract_form)
       |> reset_fees_for_selection()}
    else
      contact = Personal.get_contact!(contact_id, :contact_groups) |> dbg()

      {:noreply,
       socket
       |> assign_form(membership_contract_form)
       |> assign_fees_for_selection(contact)}
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["membership_contract_form", "contact", "type"],
          "membership_contract_form" =>
            %{"contact" => %{"type" => _} = contact} = membership_contract_form
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign_form(membership_contract_form)
     |> assign_fees_for_selection(contact)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "_target" => ["membership_contract_form", "contact", "person_birthday"],
          "membership_contract_form" => %{"contact" => contact} = membership_contract_form
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign_form(membership_contract_form)
     |> assign_fees_for_selection(contact)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "membership_contract_form" => membership_contract_form
        },
        socket
      ) do
    {:noreply,
     socket
     |> assign_form(membership_contract_form)}
  end

  def handle_event(
        "save",
        %{"membership_contract_form" => membership_contract_form},
        %{assigns: %{club: club}} = socket
      ) do
    changeset =
      socket.assigns.membership_contract_form
      |> MembershipContractForm.changeset(membership_contract_form)

    if changeset.valid? do
      membership_contract = Ecto.Changeset.apply_changes(changeset)

      contact_id =
        if membership_contract.contact_id == MembershipContractForm.new_contact_value() do
          if membership_contract.contact.id do
            membership_contract.contact.id
          else
            contact_map = Map.get(membership_contract_form, "contact")
            contact_map = Map.put(contact_map, "club_id", club.id)

            # Ensuring the save of a changeset so that inlined contacts on financial data structs receive
            # a generated identification number.
            {:ok, added_contact} =
              Personal.create_membership_contact(contact_map)

            added_contact.id
          end
        else
          membership_contract.contact_id
        end

      case contact_group_id = membership_contract.contact_group_id do
        "new" ->
          contact_group = membership_contract.contact_group

          {:ok, new_contact_group} =
            Personal.create_contact_group(Map.from_struct(contact_group))

          Personal.create_contact_group_contact(%{
            contact_id: contact_id,
            contact_group_id: new_contact_group.id
          })

        nil ->
          nil

        _ ->
          Personal.create_contact_group_contact(%{
            contact_id: contact_id,
            contact_group_id: contact_group_id
          })
      end

      case legal_guardian_id = membership_contract.legal_guardian_contact_id do
        "new" ->
          legal_guardian_contact = membership_contract.legal_guardian_contact

          {:ok, added_legal_guardian_contact} =
            Personal.create_contact_internal(legal_guardian_contact)

          Personal.create_legal_guardian_relation(
            added_legal_guardian_contact.id,
            contact_id,
            membership_contract.signing_date
          )

        "new_direct_debit_different_account_holder_contact" ->
          contact = Personal.get_contact!(contact_id, [:financial_data])

          legal_guardian_id =
            List.first(contact.financial_data).direct_debit_different_account_holder_contact_id

          Personal.create_legal_guardian_relation(
            legal_guardian_id,
            contact_id,
            membership_contract.signing_date
          )

        "new_invoice_different_recipient_contact" ->
          contact = Personal.get_contact!(contact_id, [:financial_data])

          legal_guardian_id =
            List.first(contact.financial_data).invoice_different_recipient_contact

          Personal.create_legal_guardian_relation(
            legal_guardian_id,
            contact_id,
            membership_contract.signing_date
          )

        nil ->
          nil

        _ ->
          Personal.create_legal_guardian_relation(
            legal_guardian_id,
            contact_id,
            membership_contract.signing_date
          )
      end

      club_contract = %Contract{
        club_id: club.id,
        contact_id: contact_id,
        fee_id: membership_contract.club_fee_id,
        signing_date: membership_contract.signing_date,
        start_date: membership_contract.start_date,
        clubs: [club]
      }

      Legal.create_contract_internal(club_contract)

      selected =
        membership_contract.department_selections
        |> Enum.filter(fn department_selection -> department_selection.checked end)
        |> Enum.map(fn department_selection ->
          %{
            department_selection
            | group_selections:
                department_selection.group_selections
                |> Enum.filter(fn group_selection -> group_selection.checked end)
          }
        end)

      selected
      |> Enum.each(fn department_selection ->
        department =
          club.departments
          |> Enum.find(fn department -> department.id == department_selection.id end)

        department_contract = %Contract{
          club_id: club.id,
          contact_id: contact_id,
          fee_id: department_selection.fee_id,
          signing_date: membership_contract.signing_date,
          start_date: membership_contract.start_date,
          departments: [department]
        }

        Legal.create_contract_internal(department_contract)

        department_selection.group_selections
        |> Enum.each(fn group_selection ->
          group_contract = %Contract{
            club_id: club.id,
            contact_id: contact_id,
            fee_id: group_selection.fee_id,
            signing_date: membership_contract.signing_date,
            start_date: membership_contract.start_date,
            groups: [
              department.groups |> Enum.find(fn group -> group.id == group_selection.id end)
            ]
          }

          Legal.create_contract_internal(group_contract)
        end)
      end)

      {:noreply,
       socket
       |> put_flash(:info, "Aufnahmeantrag erfolgreich erfasst.")
       |> push_navigate(to: "/clubs/#{club.id}/members")}
    else
      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :insert))}
    end
  end

  defp assign_fees_for_selection(%{assigns: %{club: club}} = socket, %{
         "type" => "organization" = type
       }) do
    contact_param = %Contact{
      club_id: club.id,
      type: type
    }

    assign_fees_for_selection(socket, contact_param)
  end

  defp assign_fees_for_selection(
         %{assigns: %{club: club}} = socket,
         %{"type" => "person" = type, "person_birthday" => person_birthday}
       ) do
    case Date.from_iso8601(person_birthday) do
      {:ok, birthday_date} ->
        contact_param = %Contact{
          club_id: club.id,
          type: type,
          person_birthday: birthday_date,
          contact_groups: []
        }

        assign_fees_for_selection(socket, contact_param)

      _ ->
        socket
        |> reset_fees_for_selection()
    end
  end

  defp assign_fees_for_selection(
         socket,
         %{"type" => "person"}
       ) do
    socket
    |> reset_fees_for_selection()
  end

  defp assign_fees_for_selection(
         socket,
         %Contact{person_birthday: nil}
       ) do
    socket
    |> reset_fees_for_selection()
  end

  defp assign_fees_for_selection(%{assigns: %{club: club}} = socket, %Contact{} = contact) do
    club_fees =
      Finance.list_contract_fee_options(club, contact)

    department_id_fees_map =
      club.departments
      |> Map.new(fn department ->
        {department.id, Finance.list_contract_fee_options(department, contact)}
      end)

    group_id_fees_map =
      socket.assigns.club.departments
      |> Enum.flat_map(fn departments -> departments.groups end)
      |> Map.new(fn group ->
        {group.id, Finance.list_contract_fee_options(group, contact)}
      end)

    socket
    |> assign(:club_fees_for_selection, club_fees)
    |> assign(:department_id_fees_map_for_selection, department_id_fees_map)
    |> assign(:group_id_fees_map_for_selection, group_id_fees_map)
  end

  defp reset_fees_for_selection(socket) do
    socket
    |> assign(:club_fees_for_selection, [])
    |> assign(:department_id_fees_map_for_selection, %{})
    |> assign(:group_id_fees_map_for_selection, %{})
  end
end
