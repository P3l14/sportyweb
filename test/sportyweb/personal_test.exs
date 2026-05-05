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

    test "delete_contact_group_contacts/1 deletes the contact_group" do
      contact_group_contact = contact_group_contact_fixture()
      assert {1, nil} = Personal.delete_contact_group_contacts([contact_group_contact.contact_id])
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

  describe "financial_data" do

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    test "create with owner ref" do
      fd = financial_data_attrs()
      c = contact_fixture(%{
        financial_data: [fd]
      })
      dbg(c)
      c = Personal.get_contact!(c.id, [:financial_data, :debit_holder, :postal_addresses, :phones, :notes, :emails])
      dbg(c)
      cs = Personal.change_contact(c)
      cs = Ecto.Changeset.put_assoc(cs, :debit_holder, c.financial_data)
      dbg(Sportyweb.Repo.update(cs))

    end

  end
end
