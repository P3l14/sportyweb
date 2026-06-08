defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """
  alias Sportyweb.LegalFixtures
  alias Sportyweb.Organization

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        type: "person",
        organization_name: "some organization_name",
        organization_type: "club",
        person_last_name: "some person_last_name",
        person_first_name: "some person_first_name",
        person_middle_names: "some person_middle_names",
        person_gender: "other",
        person_birthday: ~D[2000-02-15],
        postal_addresses: [postal_address_attrs()],
        emails: [email_attrs()],
        phones: [phone_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Personal.create_contact()

    contact
  end

  @doc """
  Creates a new contact for the given club_id with the first chairman role.
  The valid_from date defaults to the actual date minus two years.
  valid_from and valid_until can be modified by passing the atoms :chair_man_valid_from and :chair_man_valid_until.


  """
  def contact_with_first_chair_man_role_for_club_fixture(%{club_id: club_id} = attrs) do
    now = Date.utc_today()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        club_id: club_id,
        type: "person",
        person_last_name: "Chairman",
        person_first_name: "THE",
        person_gender: "other",
        person_birthday: Date.add(now, -40 * 365),
        postal_addresses: [postal_address_attrs()],
        emails: [email_attrs()],
        phones: [phone_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()],
        contact_roles: [
          %{
            valid_from: Map.get(attrs, :chair_man_valid_from, Date.add(now, -2 * 365)),
            valid_until: Map.get(attrs, :chair_man_valid_until),
            name: "first chairman"
          }
        ]
      })
      |> Sportyweb.Personal.create_contact()

    contact
  end

  @doc """
  Convienience function to create a contact with multiple contracts.
  Specific values for the contact are passed as contact keywords in the attr parameter
  Specific values for the contracts are passed as keyword maps in a list under the key :fee_contract_target_object_list


  ## Examples

      iex>       contact_with_contract_fixture(%{
                  club_id: club.id,
                  person_gender: "female",
                  fee_contract_target_object_list: [
                    %{fee: fee, contract_target_object: club},
                    %{fee: department_fee, contract_target_object: department1},
                    %{fee: department_fee, contract_target_object: department2}
                  ]
                })


  """
  def contact_with_contract_fixture(
        %{club_id: club_id, fee_contract_target_object_list: fee_contract_target_object_list} =
          attrs
      )
      when is_list(fee_contract_target_object_list) do
    contact = contact_fixture(attrs)

    fee_contract_target_object_list
    |> Enum.each(fn %{fee: fee, contract_target_object: contract_target_object} = contract_attrs ->
      contract =
        LegalFixtures.contract_fixture(
          contract_attrs
          |> Enum.into(%{
            contact_id: contact.id,
            club_id: club_id,
            fee_id: fee.id
          })
        )

      case contract_target_object do
        %Organization.Club{} ->
          Organization.create_club_contract(contract_target_object, contract)

        %Organization.Department{} ->
          Organization.create_department_contract(contract_target_object, contract)

        %Organization.Group{} ->
          Organization.create_group_contract(contract_target_object, contract)
      end
    end)

    contact
  end

  @doc """
  Generate a contact_group.
  """
  def contact_group_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact_group} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "Familie Muster"
      })
      |> Sportyweb.Personal.create_contact_group()

    contact_group
  end

  def contact_group_contact_fixture(attrs \\ %{}) do
    contact_group = contact_group_fixture()
    contact = contact_fixture()

    {:ok, contact_group_contact} =
      attrs
      |> Enum.into(%{
        contact_group_id: contact_group.id,
        contact_id: contact.id
      })
      |> Sportyweb.Personal.create_contact_group_contact()

    contact_group_contact
  end

  @doc """
  Generate a contact_role.
  """
  def contact_role_fixture(attrs \\ %{}) do
    contact = contact_fixture()

    {:ok, contact_role} =
      attrs
      |> Enum.into(%{
        contact_id: contact.id,
        name: "interested",
        valid_from: ~D[2026-03-14],
        valid_until: ~D[2026-03-14]
      })
      |> Sportyweb.Personal.create_contact_role()

    contact_role
  end

  @doc """
  Generate a contact_role_relation.
  """
  def contact_role_relation_fixture(attrs \\ %{}) do
    contact = contact_fixture()
    contact_role = contact_role_fixture()

    {:ok, contact_role_relation} =
      attrs
      |> Enum.into(%{
        contact_role_id: contact_role.id,
        contact_id: contact.id,
        valid_from: ~D[2026-05-02],
        valid_until: ~D[2026-05-02]
      })
      |> Sportyweb.Personal.create_contact_role_relation()

    contact_role_relation
  end

  @doc """
  Generate a qualification.
  """
  def qualification_fixture(attrs \\ %{}) do
    {:ok, qualification} =
      attrs
      |> Enum.into(%{
        contact_id: contact_fixture().id,
        type: "dosb license",
        dosb_first_issuance: ~D[2026-06-04],
        dosb_license_coach_sport: "Fußball",
        dosb_license_level: "B",
        dosb_license_number: "123456",
        dosb_license_number_sports_association: "123456",
        dosb_license_sport_instructor_type: "",
        dosb_license_type: "coach professional",
        dosb_valid_until: ~D[2066-06-04]
      })
      |> Sportyweb.Personal.create_qualification()

    qualification
  end

  @doc """
  Generate a qualification.
  """
  def qualification_fixture_common(attrs \\ %{}) do
    {:ok, qualification} =
      attrs
      |> Enum.into(%{
        contact_id: contact_fixture().id,
        type: "common",
        common_type: "apprenticeship",
        common_description: "Sportkaufmann",
        common_issuance: ~D[2026-06-04]
      })
      |> Sportyweb.Personal.create_qualification()

    qualification
  end
end
