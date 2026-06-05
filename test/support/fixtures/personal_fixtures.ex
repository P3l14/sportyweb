defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """

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
        common_description: "some common_description",
        common_issuance: ~D[2026-06-04],
        common_type: "some common_type",
        dosb_first_issuance: ~D[2026-06-04],
        dosb_license_coach_sport: "some dosb_license_coach_sport",
        dosb_license_level: "some dosb_license_level",
        dosb_license_number: "some dosb_license_number",
        dosb_license_number_sports_association: "some dosb_license_number_sports_association",
        dosb_license_sport_instructor_type: "some dosb_license_sport_instructor_type",
        dosb_license_type: "some dosb_license_type",
        dosb_valid_until: ~D[2026-06-04],
        type: "some type"
      })
      |> Sportyweb.Personal.create_qualification()

    qualification
  end
end
