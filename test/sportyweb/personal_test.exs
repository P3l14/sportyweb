defmodule Sportyweb.PersonalTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Personal

  describe "contacts" do
    alias Sportyweb.Personal.Contact

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      organization_name: nil,
      organization_type: nil,
      person_birthday: nil,
      person_first_name: nil,
      person_middle_names: nil,
      person_gender: nil,
      person_last_name: nil,
      type: nil
    }

    test "list_contacts/1 returns all contacts of a given club" do
      contact = contact_fixture()
      assert List.first(Personal.list_contacts(contact.club_id)).id == contact.id
    end

    test "list_contacts/2 returns all contacts of a given club with preloaded associations" do
      contact = contact_fixture()

      assert Personal.list_contacts(contact.club_id, [
               :emails,
               :financial_data,
               :notes,
               :phones,
               :postal_addresses
             ]) == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Personal.get_contact!(contact.id).id == contact.id
    end

    test "get_contact!/2 returns the contact with given id and contains preloaded associations" do
      contact = contact_fixture()

      assert Personal.get_contact!(contact.id, [
               :emails,
               :financial_data,
               :notes,
               :phones,
               :postal_addresses
             ]) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        organization_name: "some organization_name",
        organization_type: "club",
        person_birthday: ~D[2023-02-15],
        person_first_name: "some person_first_name",
        person_middle_names: "some person_middle_names",
        person_gender: "female",
        person_last_name: "some person_last_name",
        type: "person",
        emails: [email_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()],
        postal_addresses: [postal_address_attrs()]
      }

      assert {:ok, %Contact{} = contact} = Personal.create_contact(valid_attrs)
      assert contact.organization_name == "some organization_name"
      assert contact.organization_type == "club"
      assert contact.person_birthday == ~D[2023-02-15]
      assert contact.person_first_name == "some person_first_name"
      assert contact.person_middle_names == "some person_middle_names"
      assert contact.person_gender == "female"
      assert contact.person_last_name == "some person_last_name"
      assert contact.type == "person"
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()

      update_attrs = %{
        organization_name: "some updated organization_name",
        organization_type: "corporation",
        person_birthday: ~D[2023-02-16],
        person_first_name: "some updated person_first_name",
        person_middle_names: "some updated person_middle_names",
        person_gender: "male",
        person_last_name: "some updated person_last_name",
        type: "organization"
      }

      assert {:ok, %Contact{} = contact} = Personal.update_contact(contact, update_attrs)
      assert contact.organization_name == "some updated organization_name"
      assert contact.organization_type == "corporation"
      assert contact.person_birthday == ~D[2023-02-16]
      assert contact.person_first_name == "some updated person_first_name"
      assert contact.person_middle_names == "some updated person_middle_names"
      assert contact.person_gender == "male"
      assert contact.person_last_name == "some updated person_last_name"
      assert contact.type == "organization"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Personal.update_contact(contact, @invalid_attrs)

      assert contact ==
               Personal.get_contact!(contact.id, [
                 :emails,
                 :financial_data,
                 :phones,
                 :notes,
                 :postal_addresses
               ])
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Personal.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact(contact)
    end
  end

  describe "contact_groups" do
    alias Sportyweb.Personal.ContactGroup

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{club_id: nil}

    test "list_contact_groups/1 returns all contact_groups for given club" do
      contact_group = contact_group_fixture()
      assert Personal.list_contact_groups(contact_group.club_id) == [contact_group]
    end

    test "get_contact_group!/1 returns the contact_group with given id" do
      contact_group = contact_group_fixture()
      assert Personal.get_contact_group!(contact_group.id) == contact_group
    end

    test "create_contact_group/1 with valid data creates a contact_group" do
      club = club_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        club_id: club.id,
        name: "Familie Müller",
        contact_id: contact.id
      }

      assert {:ok, %ContactGroup{}} = Personal.create_contact_group(valid_attrs)
    end

    test "create_contact_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_group(@invalid_attrs)
    end

    test "update_contact_group/2 with valid data updates the contact_group" do
      contact_group = contact_group_fixture()
      update_attrs = %{}

      assert {:ok, %ContactGroup{}} = Personal.update_contact_group(contact_group, update_attrs)
    end

    test "update_contact_group/2 with invalid data returns error changeset" do
      contact_group = contact_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact_group(contact_group, @invalid_attrs)

      assert contact_group == Personal.get_contact_group!(contact_group.id)
    end

    test "delete_contact_group/1 deletes the contact_group" do
      contact_group = contact_group_fixture()
      assert {:ok, %ContactGroup{}} = Personal.delete_contact_group(contact_group)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact_group!(contact_group.id) end
    end

    test "change_contact_group/1 returns a contact_group changeset" do
      contact_group = contact_group_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact_group(contact_group)
    end
  end

  describe "contact_groups_contacts" do
    alias Sportyweb.Personal.ContactGroupContact

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{contact_group_id: nil}

    test "get_contact_group_contacts!/1 returns all contact_groups_contacts for given contact_group" do
      contact_group_contact = contact_group_contact_fixture()

      assert Personal.get_contact_group_contacts!(contact_group_contact.contact_group_id) == [
               contact_group_contact
             ]
    end

    test "create_contact_group_contact/1 with valid data creates a contact_group" do
      contact_group = contact_group_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        contact_group_id: contact_group.id,
        contact_id: contact.id
      }

      assert {:ok, %ContactGroupContact{}} = Personal.create_contact_group_contact(valid_attrs)
    end

    test "create_contact_group_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_group_contact(@invalid_attrs)
    end

    test "delete_contact_group_contact/1 deletes the contact_group" do
      contact_group_contact = contact_group_contact_fixture()
      assert [] != Personal.get_contact_group_contacts!(contact_group_contact.contact_group_id)

      assert {:ok, %ContactGroupContact{}} =
               Personal.delete_contact_group_contact(contact_group_contact)

      assert [] = Personal.get_contact_group_contacts!(contact_group_contact.contact_group_id)
    end

    test "list_contacts_for_contact_group_selection/2 only show contact not assigned to a group" do
      club = club_fixture()
      contact_group = contact_group_fixture(name: "Familie Mayer")

      contact_1 =
        contact_fixture(%{
          club_id: club.id,
          person_first_name: "Max",
          person_last_name: "Mustermann",
          person_gender: "male",
          person_birthday: ~D[2023-02-16],
          emails: [email_attrs()],
          financial_data: [financial_data_attrs()],
          notes: [note_attrs()],
          phones: [phone_attrs()],
          postal_addresses: [postal_address_attrs()]
        })

      contact_2 =
        contact_fixture(%{
          club_id: club.id,
          person_first_name: "Maria",
          person_last_name: "Mustermann",
          person_gender: "female",
          person_birthday: ~D[2023-02-16],
          emails: [email_attrs()],
          financial_data: [financial_data_attrs()],
          notes: [note_attrs()],
          phones: [phone_attrs()],
          postal_addresses: [postal_address_attrs()]
        })

      assert 2 = length(Personal.list_contacts_for_contact_group_selection(club.id))

      Personal.create_contact_group_contact(%{
        contact_group_id: contact_group.id,
        contact_id: contact_1.id
      })

      assert 1 = length(Personal.list_contacts_for_contact_group_selection(club.id))

      Personal.create_contact_group_contact(%{
        contact_group_id: contact_group.id,
        contact_id: contact_2.id
      })

      assert 0 = length(Personal.list_contacts_for_contact_group_selection(club.id))
    end

    test "create_contact_group_with_contact_group_contacts/2 success" do
      club = club_fixture()
      c1 = contact_fixture(club_id: club.id)
      c2 = contact_fixture(club_id: club.id)

      assert Personal.list_contact_groups(club.id) == []

      result =
        Personal.create_contact_group_with_contact_group_contacts(
          %{
            club_id: club.id,
            type: "family",
            name: "Smith"
          },
          %{
            "0" => %{
              "contact_id" => c1.id
            },
            "1" => %{
              "contact_id" => c2.id
            }
          }
        )

      assert {:ok, _} = result
      assert Personal.list_contact_groups(club.id) != []
    end

    test "create_contact_group_with_contact_group_contacts/2 failure due to invalid type" do
      club = club_fixture()
      c1 = contact_fixture(club_id: club.id)
      c2 = contact_fixture(club_id: club.id)

      assert Personal.list_contact_groups(club.id) == []

      result =
        Personal.create_contact_group_with_contact_group_contacts(
          %{
            club_id: club.id,
            type: "ungültiger typ",
            name: "Smith"
          },
          %{
            "0" => %{
              "contact_id" => c1.id
            },
            "1" => %{
              "contact_id" => c2.id
            }
          }
        )

      assert {:error, :contact_group, _, _} = result
      assert Personal.list_contact_groups(club.id) == []
    end

    test "create_contact_group_with_contact_group_contacts/2 failure due double contact id insert" do
      club = club_fixture()
      c1 = contact_fixture(club_id: club.id)

      assert Personal.list_contact_groups(club.id) == []

      result =
        Personal.create_contact_group_with_contact_group_contacts(
          %{
            club_id: club.id,
            type: "family",
            name: "Smith"
          },
          %{
            "0" => %{
              "contact_id" => c1.id
            },
            "1" => %{
              "contact_id" => c1.id
            }
          }
        )

      assert {:error, {:contact_group_contact, "1"}, _, _} = result
      assert Personal.list_contact_groups(club.id) == []
    end
  end

  describe "contact_roles" do
    alias Sportyweb.Personal.ContactRole

    import Sportyweb.PersonalFixtures

    @invalid_attrs %{valid_from: nil, valid_until: nil}

    test "list_contact_roles/0 returns all contact_roles" do
      contact_role = contact_role_fixture()
      assert Personal.list_contact_roles() == [contact_role]
    end

    test "get_contact_role!/1 returns the contact_role with given id" do
      contact_role = contact_role_fixture()
      assert Personal.get_contact_role!(contact_role.id) == contact_role
    end

    test "create_contact_role/1 with valid data creates a contact_role" do
      valid_attrs = %{
        valid_from: ~D[2026-03-14],
        valid_until: ~D[2026-03-14],
        name: "interested",
        contact_id: contact_fixture().id
      }

      assert {:ok, %ContactRole{} = contact_role} = Personal.create_contact_role(valid_attrs)
      assert contact_role.valid_from == ~D[2026-03-14]
      assert contact_role.valid_until == ~D[2026-03-14]
    end

    test "create_contact_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_role(@invalid_attrs)
    end

    test "update_contact_role/2 with valid data updates the contact_role" do
      contact_role = contact_role_fixture()
      update_attrs = %{valid_from: ~D[2026-03-15], valid_until: ~D[2026-03-15]}

      assert {:ok, %ContactRole{} = contact_role} =
               Personal.update_contact_role(contact_role, update_attrs)

      assert contact_role.valid_from == ~D[2026-03-15]
      assert contact_role.valid_until == ~D[2026-03-15]
    end

    test "update_contact_role/2 with invalid data returns error changeset" do
      contact_role = contact_role_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact_role(contact_role, @invalid_attrs)

      assert contact_role == Personal.get_contact_role!(contact_role.id)
    end

    test "delete_contact_role/1 deletes the contact_role" do
      contact_role = contact_role_fixture()
      assert {:ok, %ContactRole{}} = Personal.delete_contact_role(contact_role)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact_role!(contact_role.id) end
    end

    test "change_contact_role/1 returns a contact_role changeset" do
      contact_role = contact_role_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact_role(contact_role)
    end
  end

  describe "contact_short" do
    alias Sportyweb.Personal.Contact
    alias Sportyweb.Personal.ContactRole

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{type: nil, club_id: nil}

    test "create_short_contact/1 with valid data creates a short contact with minimal personal data" do
      valid_attrs = %{
        type: "person",
        club_id: club_fixture().id,
        person_last_name: "Schmidt",
        person_first_name: "Sebastian",
        contact_roles: [
          %{valid_from: ~D[2026-03-14], valid_until: ~D[2026-03-14], name: "interested"}
        ]
      }

      assert {:ok, %Contact{} = contact} = Personal.create_short_contact(valid_attrs)
      assert contact.person_last_name == "Schmidt"
      assert contact.person_first_name == "Sebastian"
      assert List.first(contact.contact_roles).name == "interested"
    end

    test "create_short_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_short_contact(@invalid_attrs)
    end
  end

  describe "contact_role_relations" do
    alias Sportyweb.Personal.ContactRoleRelation
    alias Sportyweb.Personal.ContactRole

    import Sportyweb.PersonalFixtures

    @invalid_attrs %{valid_from: nil, valid_until: nil}

    test "list_contact_role_relations/0 returns all contact_role_relations" do
      contact_role_relation = contact_role_relation_fixture()
      assert Personal.list_contact_role_relations() == [contact_role_relation]
    end

    test "get_contact_role_relation!/1 returns the contact_role_relation with given id" do
      contact_role_relation = contact_role_relation_fixture()

      assert Personal.get_contact_role_relation!(contact_role_relation.id) ==
               contact_role_relation
    end

    test "create_contact_role_relation/1 with valid data creates a contact_role_relation" do
      contact = contact_fixture()
      contact_role = contact_role_fixture()

      valid_attrs = %{
        contact_role_id: contact_role.id,
        contact_id: contact.id,
        valid_from: ~D[2026-05-02],
        valid_until: ~D[2026-05-02]
      }

      assert {:ok, %ContactRoleRelation{} = contact_role_relation} =
               Personal.create_contact_role_relation(valid_attrs)

      assert contact_role_relation.valid_from == ~D[2026-05-02]
      assert contact_role_relation.valid_until == ~D[2026-05-02]
    end

    test "create_contact_role_relation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_role_relation(@invalid_attrs)
    end

    test "update_contact_role_relation/2 with valid data updates the contact_role_relation" do
      contact_role_relation = contact_role_relation_fixture()
      update_attrs = %{valid_from: ~D[2026-05-03], valid_until: ~D[2026-05-03]}

      assert {:ok, %ContactRoleRelation{} = contact_role_relation} =
               Personal.update_contact_role_relation(contact_role_relation, update_attrs)

      assert contact_role_relation.valid_from == ~D[2026-05-03]
      assert contact_role_relation.valid_until == ~D[2026-05-03]
    end

    test "update_contact_role_relation/2 with invalid data returns error changeset" do
      contact_role_relation = contact_role_relation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact_role_relation(contact_role_relation, @invalid_attrs)

      assert contact_role_relation ==
               Personal.get_contact_role_relation!(contact_role_relation.id)
    end

    test "delete_contact_role_relation/1 deletes the contact_role_relation" do
      contact_role_relation = contact_role_relation_fixture()

      assert {:ok, %ContactRoleRelation{}} =
               Personal.delete_contact_role_relation(contact_role_relation)

      assert_raise Ecto.NoResultsError, fn ->
        Personal.get_contact_role_relation!(contact_role_relation.id)
      end
    end

    test "change_contact_role_relation/1 returns a contact_role_relation changeset" do
      contact_role_relation = contact_role_relation_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact_role_relation(contact_role_relation)
    end

    test "create_legal_guardian_relation/3 creates a relation and a role" do
      legal_guardian = contact_fixture()
      underage = contact_fixture()
      today = Date.utc_today()
      assert [] = Personal.list_contact_roles()
      assert [] = Personal.list_contact_role_relations()
      Personal.create_legal_guardian_relation(legal_guardian.id, underage.id, today)
      assert 1 = length(Personal.list_contact_roles())
      assert 1 = length(Personal.list_contact_role_relations())
    end

    test "create_legal_guardian_relation/3 while legal guradian role exists appends a relation to the existing role" do
      underage_b = contact_fixture()
      two_years_ago = Date.add(Date.utc_today(), -2 * 365)
      two_years_in_future = Date.add(Date.utc_today(), 2 * 365)

      role =
        contact_role_fixture(%{
          name: "legal guardian",
          valid_from: two_years_ago,
          valid_until: two_years_in_future,
          contact_role_relations: [
            %{
              contact_id: underage_b.id,
              valid_from: two_years_ago,
              valid_until: two_years_in_future
            }
          ]
        })

      underage = contact_fixture()
      today = Date.utc_today()
      assert 1 = length(Personal.list_contact_roles())
      assert 1 = length(Personal.list_contact_role_relations())
      Personal.create_legal_guardian_relation(role.contact_id, underage.id, today)
      assert 1 = length(Personal.list_contact_roles())
      assert 2 = length(Personal.list_contact_role_relations())
    end

    test "is_in_use/2 valid today" do
      two_years_ago = Date.add(Date.utc_today(), -2 * 365)

      role =
        contact_role_fixture(%{
          name: "legal guardian",
          valid_from: two_years_ago,
          valid_until: nil
        })

      assert role |> ContactRole.is_in_use?()
    end

    test "is_in_use/2 valid_from future date invalid today" do
      two_years_in_future = Date.add(Date.utc_today(), 2 * 365)

      role =
        contact_role_fixture(%{
          name: "legal guardian",
          valid_from: two_years_in_future,
          valid_until: nil
        })

      assert not (role |> ContactRole.is_in_use?())
    end

    test "is_in_use/2 valid_until past invalid today" do
      two_years_ago = Date.add(Date.utc_today(), -2 * 365)
      one_years_ago = Date.add(Date.utc_today(), -1 * 365)

      role =
        contact_role_fixture(%{
          name: "legal guardian",
          valid_from: two_years_ago,
          valid_until: one_years_ago
        })

      assert not (role |> ContactRole.is_in_use?())
    end

    alias Sportyweb.Personal.Contact
    import Sportyweb.OrganizationFixtures

    test "Personal.create_contact with role and relation returns contact with a role and a relation" do
      contact = contact_fixture()

      valid_attrs = %{
        type: "person",
        club_id: club_fixture().id,
        person_last_name: "Schmidt",
        person_first_name: "Selona",
        person_birthday: Faker.Date.date_of_birth(25),
        postal_addresses: [Sportyweb.PolymorphicFixtures.postal_address_attrs()],
        contact_roles: [
          %{
            valid_from: ~D[2026-03-14],
            valid_until: ~D[2026-03-14],
            name: "legal guardian",
            contact_role_relations: [
              %{
                contact_id: contact.id,
                valid_from: ~D[2026-03-14],
                valid_until: ~D[2026-03-14]
              }
            ]
          }
        ]
      }

      assert {:ok, %Contact{}} = Personal.create_short_contact(valid_attrs)
    end
  end

  describe "qualifications" do
    alias Sportyweb.Personal.Qualification

    import Sportyweb.PersonalFixtures

    @invalid_attrs %{
      type: nil,
      dosb_license_type: nil,
      dosb_license_level: nil,
      dosb_license_number: nil,
      dosb_license_number_sports_association: nil,
      dosb_license_coach_sport: nil,
      dosb_license_sport_instructor_type: nil,
      dosb_first_issuance: nil,
      dosb_valid_until: nil,
      common_type: nil,
      common_description: nil,
      common_issuance: nil
    }

    test "list_qualifications/0 returns all qualifications" do
      qualification = qualification_fixture()
      assert Personal.list_qualifications() == [qualification]
    end

    test "get_qualification!/1 returns the qualification with given id" do
      qualification = qualification_fixture()
      assert Personal.get_qualification!(qualification.id) == qualification
    end

    test "create_qualification/1 with valid data creates a qualification" do
      contact_id = contact_fixture().id

      valid_attrs = %{
        contact_id: contact_id,
        type: "dosb license",
        dosb_first_issuance: ~D[2022-06-04],
        dosb_license_coach_sport: "Handball",
        dosb_license_level: "B",
        dosb_license_number: "987",
        dosb_license_number_sports_association: "369",
        dosb_license_sport_instructor_type: "prevention",
        dosb_license_type: "sport instructor",
        dosb_valid_until: ~D[2031-06-04]
      }

      assert {:ok, %Qualification{} = qualification} = Personal.create_qualification(valid_attrs)
      assert qualification.contact_id == contact_id
      assert qualification.type == "dosb license"
      assert qualification.dosb_license_type == "sport instructor"
      assert qualification.dosb_license_level == "B"
      assert qualification.dosb_license_number == "987"
      assert qualification.dosb_license_number_sports_association == "369"
      assert qualification.dosb_license_sport_instructor_type == "prevention"
      assert qualification.dosb_first_issuance == ~D[2022-06-04]
      assert qualification.dosb_valid_until == ~D[2031-06-04]
    end

    test "create_qualification/1 with valid data creates a common qualification" do
      contact_id = contact_fixture().id

      valid_attrs = %{
        contact_id: contact_id,
        type: "common",
        common_issuance: ~D[2022-06-04],
        common_type: "academic",
        common_description: "Bachelor in Sportwissenschaften"
      }

      assert {:ok, %Qualification{} = qualification} = Personal.create_qualification(valid_attrs)
      assert qualification.contact_id == contact_id
      assert qualification.type == "common"
      assert qualification.common_type == "academic"
      assert qualification.common_description == "Bachelor in Sportwissenschaften"
      assert qualification.common_issuance == ~D[2022-06-04]
    end

    test "create_qualification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_qualification(@invalid_attrs)
    end

    test "update_qualification/2 with valid data updates the qualification" do
      qualification = qualification_fixture()

      update_attrs = %{
        dosb_license_type: "coach common",
        dosb_license_level: "A",
        dosb_license_number: "654",
        dosb_license_number_sports_association: "321",
        dosb_license_coach_sport: "Tennis",
        dosb_first_issuance: ~D[2026-06-05],
        dosb_valid_until: ~D[2030-06-05]
      }

      assert {:ok, %Qualification{} = qualification} =
               Personal.update_qualification(qualification, update_attrs)

      assert qualification.dosb_license_type == "coach common"
      assert qualification.dosb_license_level == "A"
      assert qualification.dosb_license_number == "654"
      assert qualification.dosb_license_number_sports_association == "321"
      assert qualification.dosb_license_coach_sport == "Tennis"
      assert qualification.dosb_first_issuance == ~D[2026-06-05]
      assert qualification.dosb_valid_until == ~D[2030-06-05]
    end

    test "update_qualification/2 with valid data updates the common qualification" do
      qualification = qualification_fixture()

      update_attrs = %{
        type: "common",
        common_issuance: ~D[2024-06-04],
        common_type: "academic",
        common_description: "Master in Sportmanagment"
      }

      assert {:ok, %Qualification{} = qualification} =
               Personal.update_qualification(qualification, update_attrs)

      assert qualification.type == "common"
      assert qualification.common_type == "academic"
      assert qualification.common_description == "Master in Sportmanagment"
      assert qualification.common_issuance == ~D[2024-06-04]
    end

    test "update_qualification/2 with invalid data returns error changeset" do
      qualification = qualification_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_qualification(qualification, @invalid_attrs)

      assert qualification == Personal.get_qualification!(qualification.id)
    end

    test "delete_qualification/1 deletes the qualification" do
      qualification = qualification_fixture()
      assert {:ok, %Qualification{}} = Personal.delete_qualification(qualification)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_qualification!(qualification.id) end
    end

    test "change_qualification/1 returns a qualification changeset" do
      qualification = qualification_fixture()
      assert %Ecto.Changeset{} = Personal.change_qualification(qualification)
    end
  end

  describe "member inventory" do
    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.FinanceFixtures
    import SweetXml
    alias Sportyweb.Organization

    test "create_member_inventory_document/2 for club without departments returns a member inventory document" do
      club =
        club_fixture(%{
          name: "DER Verein",
          association_number: "123",
          affiliated_sports_federation: "12",
          departments: []
        })

      contact_with_first_chair_man_role_for_club_fixture(%{club_id: club.id})

      club = Organization.get_club!(club.id, :departments)
      fee = fee_fixture()

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        person_birthday: ~D[1999-02-15],
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "female",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "other",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "no_info",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      xml = Personal.create_member_inventory_document(club, Date.utc_today())

      assert xml |> xpath(~x"/Mitglieder/Software/Schluessel/text()"s) =~ "Sportyweb"
      assert xml |> xpath(~x"/Mitglieder/Verein/Nummer/text()"s) =~ club.association_number
      assert xml |> xpath(~x"/Mitglieder/Verein/Ansprechpartner/text()"s) =~ "THE Chairman"
      assert xml |> xpath(~x"/Mitglieder/Verein/Bezeichnung/text()"s) =~ club.name
      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='A'][1]/Typ/text()"s) =~ "A"
      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='A'][1]/Fachverband/text()"s) =~ ""

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='A' and Jahrgang='1999'][1]/AnzahlM/text()"s
             ) =~ "1"

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='A' and Jahrgang='2000'][1]/AnzahlM/text()"s
             ) =~ "2"

      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='B'][1]/Typ/text()"s) =~ "B"

      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='B'][1]/Fachverband/text()"s) =~
               club.association_number
    end

    test "create_member_inventory_document/2 for club with departments returns a member inventory document" do
      club =
        club_fixture(%{
          name: "DER Mehrsparten Verein",
          association_number: "123"
        })

      contact_with_first_chair_man_role_for_club_fixture(%{club_id: club.id})

      department1 =
        department_fixture(%{
          club_id: club.id,
          name: "Taekwondoabteilung",
          affiliated_sports_federation: "80"
        })

      department2 =
        department_fixture(%{
          club_id: club.id,
          name: "Karateabteilung",
          affiliated_sports_federation: "43"
        })

      club = Organization.get_club!(club.id, :departments)
      fee = fee_fixture()
      department_fee = fee_fixture(type: "department")

      now = Date.utc_today()

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        person_birthday: ~D[1999-02-15],
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      # Adding a contact with archived contracts which should not be counted.
      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{
            fee: department_fee,
            contract_target_object: department1,
            archive_date: Date.add(now, -2 * 365)
          },
          %{
            fee: department_fee,
            contract_target_object: department2,
            archive_date: Date.add(now, -2 * 365)
          }
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "other",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "no_info",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      xml = Personal.create_member_inventory_document(club, now)

      assert xml |> xpath(~x"/Mitglieder/Software/Schluessel/text()"s) =~ "Sportyweb"
      assert xml |> xpath(~x"/Mitglieder/Verein/Nummer/text()"s) =~ club.association_number
      assert xml |> xpath(~x"/Mitglieder/Verein/Bezeichnung/text()"s) =~ club.name
      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='A'][1]/Typ/text()"s) =~ "A"
      assert xml |> xpath(~x"/Mitglieder/Zahlen[Typ/text()='A'][1]/Fachverband/text()"s) =~ ""

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='A' and Jahrgang='1999'][1]/AnzahlM/text()"s
             ) =~ "1"

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='A' and Jahrgang='2000'][1]/AnzahlM/text()"s
             ) =~ "2"

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='B' and Jahrgang='1999' and Fachverband='80'][1]/AnzahlM/text()"s
             ) =~ "1"

      assert xml
             |> xpath(
               ~x"/Mitglieder/Zahlen[Typ/text()='B' and Jahrgang='2000' and Fachverband='80'][1]/AnzahlW/text()"s
             ) =~ "2"
    end

    test "create_member_inventory_document_xlsx/2 for club without departments returns a member inventory document" do
      club =
        club_fixture(%{
          name: "DER Verein",
          association_number: "123",
          affiliated_sports_federation: "12",
          departments: []
        })

      contact_with_first_chair_man_role_for_club_fixture(%{club_id: club.id})

      club = Organization.get_club!(club.id, :departments)
      fee = fee_fixture()

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "John",
        person_last_name: "Johnsen",
        person_gender: "male",
        person_birthday: ~D[1999-02-15],
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Theo",
        person_last_name: "Test",
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Peter",
        person_last_name: "Porsche",
        club_id: club.id,
        person_gender: "male",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Maria",
        person_last_name: "Muster",
        club_id: club.id,
        person_gender: "female",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Markus",
        person_last_name: "Maxen",
        club_id: club.id,
        person_gender: "other",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Benjamin",
        person_last_name: "Bauer",
        club_id: club.id,
        person_gender: "no_info",
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

      binary_data = Personal.create_member_inventory_document_xlsx(club, Date.utc_today())

      {:ok, xlsx_data} = XlsxReader.open(binary_data, source: :binary)

      {:ok, xlsx_sheet_rows} =
        xlsx_data
        |> XlsxReader.sheet("Mitgliederliste")

      [header | data_rows] = xlsx_sheet_rows
      assert header == ["Name", "Vorname", "Geschlecht", "Geburtsdatum", "Abteilungen"]
      assert data_rows |> Enum.at(0) == ["Bauer", "Benjamin", "O", "15.02.2000", "12"]
      # Enum.at(4) -> value of Abteilungen for row
      rows_by_abteilungen = data_rows |> Enum.group_by(fn row -> row |> Enum.at(4) end)
      abteilungen_in_inventory_list = Map.keys(rows_by_abteilungen)
      assert abteilungen_in_inventory_list == ["12"]
    end

    test "create_member_inventory_document_xlsx/2 for club with departments returns a member inventory document" do
      club =
        club_fixture(%{
          name: "DER Mehrsparten Verein",
          association_number: "123"
        })

      contact_with_first_chair_man_role_for_club_fixture(%{club_id: club.id})

      department1 =
        department_fixture(%{
          club_id: club.id,
          name: "Taekwondoabteilung",
          affiliated_sports_federation: "80"
        })

      department2 =
        department_fixture(%{
          club_id: club.id,
          name: "Karateabteilung",
          affiliated_sports_federation: "43"
        })

      club = Organization.get_club!(club.id, :departments)
      fee = fee_fixture()
      department_fee = fee_fixture(type: "department")

      now = Date.utc_today()

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Lukas",
        person_last_name: "Liebig",
        person_gender: "male",
        person_birthday: ~D[1999-02-15],
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_gender: "male",
        person_first_name: "Simon",
        person_last_name: "Simsen",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Lars",
        person_last_name: "Lustig",
        person_gender: "male",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Lisa",
        person_last_name: "Lacher",
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      # Adding a contact with archived contracts which should not be counted.
      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Katharina",
        person_last_name: "Klassen",
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{
            fee: department_fee,
            contract_target_object: department1,
            archive_date: Date.add(now, -2 * 365)
          },
          %{
            fee: department_fee,
            contract_target_object: department2,
            archive_date: Date.add(now, -2 * 365)
          }
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Paulina",
        person_last_name: "Panzer",
        person_gender: "female",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        club_id: club.id,
        person_first_name: "Marlon",
        person_last_name: "Muster",
        person_gender: "other",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department1}
        ]
      })

      contact_with_contract_fixture(%{
        person_first_name: "Michael",
        person_last_name: "Müller",
        club_id: club.id,
        person_gender: "no_info",
        fee_contract_target_object_list: [
          %{fee: fee, contract_target_object: club},
          %{fee: department_fee, contract_target_object: department2}
        ]
      })

      binary_data = Personal.create_member_inventory_document_xlsx(club, now)
      {:ok, xlsx_data} = XlsxReader.open(binary_data, source: :binary)

      {:ok, xlsx_sheet_rows} =
        xlsx_data
        |> XlsxReader.sheet("Mitgliederliste")

      [header | data_rows] = xlsx_sheet_rows
      assert header == ["Name", "Vorname", "Geschlecht", "Geburtsdatum", "Abteilungen"]
      assert data_rows |> Enum.at(0) == ["Lacher", "Lisa", "F", "15.02.2000", "43"]
      assert data_rows |> Enum.at(1) == ["Lacher", "Lisa", "F", "15.02.2000", "80"]
      # Enum.at(4) -> value of Abteilungen for row
      rows_by_abteilungen = data_rows |> Enum.group_by(fn row -> row |> Enum.at(4) end)
      abteilungen_in_inventory_list = rows_by_abteilungen |> Map.keys() |> Enum.sort()
      assert abteilungen_in_inventory_list == ["43", "80"]
    end
  end

  describe "contact identification number" do
    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.FinanceFixtures
    alias Sportyweb.Personal.ContactIdentificationNumber

    test "generate_new/1 generates a new identification number for the contact of a club" do
      club = club_fixture()
      assert 10_000_004 == ContactIdentificationNumber.generate_new(club.id)
      assert 10_000_012 == ContactIdentificationNumber.generate_new(club.id)
    end

    test "generate_new/1 generates a new identification number for the contact of different clubs independently" do
      club1 = club_fixture()
      assert 10_000_004 == ContactIdentificationNumber.generate_new(club1.id)
      assert 10_000_012 == ContactIdentificationNumber.generate_new(club1.id)
      club2 = club_fixture()
      assert 10_000_004 == ContactIdentificationNumber.generate_new(club2.id)
      assert 10_000_012 == ContactIdentificationNumber.generate_new(club2.id)

      assert 10_000_020 == ContactIdentificationNumber.generate_new(club1.id)
    end

    test "valid?/1 delivers true for valid contact identification number" do
      assert ContactIdentificationNumber.valid?(10_021_277)
    end

    test "valid?/1 delivers true for generated contact identification number" do
      club = club_fixture()

      assert club.id
             |> ContactIdentificationNumber.generate_new()
             |> ContactIdentificationNumber.valid?()
    end

    test "valid?/1 delivers false for invalid contact identification number when numers are interchanged in order" do
      refute ContactIdentificationNumber.valid?(10_201_277)
      refute ContactIdentificationNumber.valid?(10_012_277)
      refute ContactIdentificationNumber.valid?(10_022_177)
      refute ContactIdentificationNumber.valid?(10_021_727)
    end
  end

  describe "contact search" do
    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.FinanceFixtures
    alias Sportyweb.Personal.ContactIdentificationNumber

    test "search/1 contact_identification_number should not find contact with unfitting contact_identification_number" do
      contact = contact_fixture()

      search_result =
        Personal.search(%{
          "club_id" => contact.club_id,
          "type" => "contact_identification_number",
          "contact_identification_number" => 13_371_337
        })

      assert search_result == []
    end

    test "search/1 contact_identification_number should find contact with contact_identification_number" do
      contact = contact_fixture()

      [found_contact] =
        Personal.search(%{
          "club_id" => contact.club_id,
          "type" => "contact_identification_number",
          "contact_identification_number" => contact.identification_number
        })

      assert contact.identification_number == found_contact.identification_number
      assert contact.name == found_contact.name
    end

    test "search/1 contact should find contacts with matching person_last_name" do
      club_id = club_fixture().id

      contact1 =
        contact_fixture(%{
          club_id: club_id,
          person_last_name: "Mustermann",
          person_first_name: "Max"
        })

      contact2 =
        contact_fixture(%{
          club_id: club_id,
          person_last_name: "Mustermann",
          person_first_name: "Maria"
        })

      contact_fixture(%{
        club_id: club_id,
        person_last_name: "Panzer",
        person_first_name: "Paul"
      })

      search_result =
        Personal.search(%{
          "club_id" => contact1.club_id,
          "type" => "contact",
          "search_scope" => "all",
          "include_invalid" => "true",
          "contact" => %{
            "type" => "person",
            "person_last_name" => "Mustermann"
          }
        })

      assert length(search_result) == 2
      [found_contact1, found_contact2] = search_result
      assert contact1.person_last_name == found_contact1.person_last_name
      assert contact2.person_last_name == found_contact2.person_last_name
      assert found_contact1.person_first_name != found_contact2.person_first_name
    end

    test "search/1 contact should find contacts with matching person data" do
      club_id = club_fixture().id

      contact1 =
        contact_fixture(%{
          club_id: club_id,
          person_last_name: "Mustermann",
          person_birth_name: "Muster",
          person_middle_names: "Marius Markus",
          person_first_name: "Max",
          person_birthday: ~D[1986-09-01],
          person_gender: "no_info",
          contact_roles: [
            %{valid_from: Date.add(Date.utc_today(), -2 * 365), name: "interested"}
          ]
        })

      contact_fixture(%{
        club_id: club_id,
        person_last_name: "Mustermann",
        person_first_name: "Maria"
      })

      search_result =
        Personal.search(%{
          "club_id" => contact1.club_id,
          "type" => "contact",
          "search_scope" => "without_members",
          "include_invalid" => "false",
          "contact" => %{
            "type" => "person",
            "person_last_name" => "Mustermann",
            "person_birth_name" => "Muster",
            "person_middle_names" => "Marius Markus",
            "person_first_name" => "Max",
            "person_birthday" => ~D[1986-09-01],
            "person_gender" => "no_info"
          }
        })

      assert length(search_result) == 1
      [found_contact1] = search_result
      assert contact1.person_last_name == found_contact1.person_last_name
      assert contact1.person_middle_names == found_contact1.person_middle_names
    end
  end
end
