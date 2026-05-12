defmodule SportywebWeb.ClubLive.MembershipContract do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
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
            <.inputs_for :let={contact} field={@form[:contact]}>
              <.input_grid>
                <div class="col-span-12">
                  <!-- Don't remove the id of the div, otherwise LiveView doesn't remove the input in step 2. -->
                  <.input
                    field={contact[:type]}
                    type="select"
                    label="Art"
                    options={Contact.get_valid_types()}
                  />
                </div>
              </.input_grid>

              <%= if contact[:type].value == "organization" do %>
                <.input_grid>
                  <div class="col-span-12 md:col-span-6">
                    <.input field={contact[:organization_name]} type="text" label="Organisationsname" />
                  </div>

                  <div class="col-span-12 md:col-span-6">
                    <.input
                      field={contact[:organization_type]}
                      type="select"
                      label="Organisationstyp"
                      options={Contact.get_valid_organization_types()}
                      prompt="Bitte auswählen"
                    />
                  </div>
                </.input_grid>
              <% else %>
                <.input_grid>
                  <div class="col-span-12 md:col-span-4">
                    <.input field={contact[:person_last_name]} type="text" label="Nachname" />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input field={contact[:person_first_name]} type="text" label="Vorname" />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input
                      field={contact[:person_middle_names]}
                      type="text"
                      label="weitere Vornamen (optional)"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input
                      field={contact[:person_birth_name]}
                      type="text"
                      label="Geburtsname (optional)"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input
                      field={contact[:person_gender]}
                      type="select"
                      label="Geschlecht"
                      options={Contact.get_valid_genders()}
                      prompt="Bitte auswählen"
                    />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input field={contact[:person_birthday]} type="date" label="Geburtsdatum" />
                  </div>
                </.input_grid>
              <% end %>

              <.input_grid :if={Contact.underage_person?(contact[:person_birthday].value)}>
                <div class="col-span-12 md:col-span-11">
                  <.input
                    field={contact[:legal_gurardian_id]}
                    type="select"
                    label="Erziehungsberechtigter"
                    options={@contact_options}
                    prompt="Bitte auswählen"
                  />
                </div>
              </.input_grid>

              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render
                  form={contact}
                  allow_multiple={true}
                  zipcode_proposals={@zipcode_proposals}
                  street_proposals={@street_proposals}
                />
              </.input_grid>

              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.EmailsFormComponent.render
                  form={contact}
                  allow_multiple={true}
                />
              </.input_grid>

              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.PhonesFormComponent.render
                  form={contact}
                  allow_multiple={true}
                />
              </.input_grid>

              <.input_grid :if={Contact.underage_person?(contact[:person_birthday].value)}>
                <div class="col-span-12 md:col-span-11">
                  <.input
                    field={contact[:legal_gurardian_id]}
                    type="select"
                    label="Erziehungsberechtigter"
                    options={@contact_options}
                    prompt="Bitte auswählen"
                  />
                </div>
              </.input_grid>
            </.inputs_for>

            <.input_grid>
              <.header level="2" class="col-span-12 md:col-span-12">
                Angabe weiterer Personen bei Familienmitgliedschaften
              </.header>
            </.input_grid>

            <.input_grid>
              <.header level="2" class="col-span-12 md:col-span-12">
                Abteilungen
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
                      |> Map.get(department_selection[:id].value)
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
                        @department_id_fees_map_for_selection
                        |> Map.get(department_selection[:id].value)
                        |> Enum.map(&{&1.name, &1.id})
                      }
                      prompt="Bitte auswählen"
                      disabled={!group_selection[:checked].value}
                    />
                  </div>
                </.inputs_for>
              </.inputs_for>
            </.input_grid>
            <.inputs_for :let={contact} field={@form[:contact]}>
              <.input_grid class="pt-6">
                <SportywebWeb.PolymorphicLive.FinancialDataFormComponent.render form={contact} />
              </.input_grid>
            </.inputs_for>
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
    club = Organization.get_club!(club_id, departments: [:fees, :groups])
    club_fees = Finance.list_club_fees(club_id)

    contact = %Contact{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      financial_data: [%FinancialData{}],
      notes: [%Note{}]
    }

    membership_contract_form = %MembershipContractForm{
      signing_date: Date.utc_today(),
      contact: contact,
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

    department_id_fees_map =
      Map.new(club.departments, fn department -> {department.id, department.fees} end)

    # TODO sprechenderer Bezeichner!
    contact_options =
      club.id
      |> Personal.list_contacts_for_contact_role_legal_gurdian_selection()
      |> Enum.map(fn contact -> [key: contact.name, value: contact.id] end)

    {:noreply,
     socket
     |> assign(:title, "Aufnahmeantragserfassung")
     |> assign(:contact, contact)
     |> assign(:membership_contract_form, membership_contract_form)
     |> assign(:contact_options, contact_options)
     |> assign_new(:form, fn ->
       to_form(MembershipContractForm.changeset(membership_contract_form))
     end)
     |> assign(:club, club)
     |> assign(:club_fees, club_fees)
     |> assign(:club_fees_for_selection, club_fees)
     |> assign(:department_id_fees_map, department_id_fees_map)
     |> assign(:department_id_fees_map_for_selection, department_id_fees_map)
     |> SportywebWeb.PolymorphicLive.FinancialDataFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2,
       "contact"
     )
     |> SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.setup_validation_and_proposal_event_hook(
       &assign_form/2,
       "contact"
     )}
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
        "validate",
        %{"membership_contract_form" => membership_contract_form},
        socket
      ) do
    changeset =
      socket.assigns.membership_contract_form
      |> MembershipContractForm.changeset(membership_contract_form)
      |> Map.put(:action, :validate)

    birthday = get_in(membership_contract_form, ["contact", "person_birthday"])

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign_club_fees_for_selection(birthday)}
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

      contact =
        if membership_contract.contact.id do
          membership_contract.contact
        else
          {:ok, added} = Personal.create_contact_internal(membership_contract.contact)
          added
        end

      legal_gurardian_id = get_in(membership_contract_form, ["contact", "legal_gurardian_id"])

      if legal_gurardian_id do
        Personal.create_legal_guardian_relation(
          legal_gurardian_id,
          contact.id,
          membership_contract.signing_date
        )
      end

      club_contract = %Contract{
        club_id: club.id,
        contact_id: contact.id,
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
          contact_id: contact.id,
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
            contact_id: contact.id,
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

    # contact_params =
    #   Enum.into(contact_params, %{
    #     "club_id" => socket.assigns.contact.club.id
    #   })

    # case dbg(Personal.create_membership_contact(contact_params)) do
    #   {:ok, _contact} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:info, "Kontakt erfolgreich erstellt")
    #      |> push_navigate(to: ~p"/clubs/#{socket.assigns.contact.club}/contacts")}

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     {:noreply, assign(socket, form: to_form(changeset))}
    # end
  end

  defp assign_club_fees_for_selection(socket, birthday) do
    if is_nil(birthday) do
      socket
      |> assign(:club_fees_for_selection, socket.assigns.club_fees)
    else
      case Date.from_iso8601(birthday) do
        {:ok, birthday_date} ->
          age_in_years = Contact.age_in_years(birthday_date)

          socket
          |> assign(
            :club_fees_for_selection,
            socket.assigns.club_fees
            |> Enum.filter(fn fee ->
              age_in_years > fee.minimum_age_in_years and age_in_years < fee.maximum_age_in_years
            end)
          )

        _ ->
          socket
          |> assign(:club_fees_for_selection, socket.assigns.club_fees)
      end
    end
  end
end
