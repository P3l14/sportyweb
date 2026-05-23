defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Personal.ContactRoleRelation
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.ContactGroupContact

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(1)
      [%Contact{}, ...]

  """
  def list_contacts(club_id) do
    query = from(c in Contact, where: c.club_id == ^club_id, order_by: c.name)
    Repo.all(query)
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(1)
      [%Contact{}, ...]

  """
  def list_contacts_for_contact_group_selection(club_id, contact_ids_of_group \\ []) do
    contacts_already_assigend_to_a_group =
      from(cgc in ContactGroupContact, select: cgc.contact_id)

    query =
      from(c in Contact,
        where:
          c.club_id == ^club_id and
            (c.id not in subquery(contacts_already_assigend_to_a_group) or
               c.id in ^contact_ids_of_group),
        order_by: c.name
      )

    Repo.all(query)
  end

  @doc """
  Lists all adult contacts for selection as legal guradian.


  """
  def list_contacts_for_contact_role_legal_gurdian_selection(club_id) do
    eighteen_years_ago = Date.add(Date.utc_today(), -18 * 365)

    query =
      from(c in Contact,
        where:
          c.club_id == ^club_id and
            c.type == "person" and
            c.person_birthday <= ^eighteen_years_ago,
        order_by: c.name
      )

    Repo.all(query)
  end

  def list_underage_contacts_for_contact_role_reltation_to_legal_gurdian_selection(club_id) do
    eighteen_years_ago = Date.add(Date.utc_today(), -18 * 365)

    query =
      from(c in Contact,
        where:
          c.club_id == ^club_id and
            c.type == "person" and
            c.person_birthday > ^eighteen_years_ago,
        order_by: c.name
      )

    Repo.all(query)
  end

  @doc """
  Returns a clubs list of contacts. Preloads associations.

  ## Examples

      iex> list_contacts(1, [:club])
      [%Contact{}, ...]

  """
  def list_contacts(club_id, preloads) do
    Repo.preload(list_contacts(club_id), preloads)
  end

  @doc """
  Returns a list of contacts that are possible options for the given contract.
  The list won't include contacts that have an active (non-archived) contract
  with the given contract_object.

  Example: If the contract_object is a certain club, all contacts which have
  active membership contracts with this club won't be part of the returned
  options list.

  ## Examples

      iex> list_contract_contact_options(1, 2)
      [%Contact{}, ...]

  """
  def list_contract_contact_options(%Contract{club_id: club_id}, contract_object) do
    list_contract_contact_options(club_id, contract_object)
  end

  def list_contract_contact_options(club_id, contract_object) when is_binary(club_id) do
    # Get all the ids of contacts that have an active contract with the contract_object.
    # These contacts won't appear in the select input as an option for the new contract.
    exclude_contact_ids =
      Enum.map(contract_object.contracts, fn contract ->
        if !Contract.is_archived?(contract, Date.utc_today()) do
          contract.contact_id
        end
      end)

    query =
      from(
        c in Contact,
        where: c.club_id == ^club_id,
        where: c.id not in ^exclude_contact_ids,
        order_by: c.name
      )

    Repo.all(query)
  end

  def find_person_contacts(club_id, person_last_name, person_first_name, person_birthday) do
    query =
      from(
        c in Contact,
        where: c.club_id == ^club_id,
        order_by: c.person_last_name,
        where: c.type == "person",
        where: like(c.person_last_name, ^person_last_name),
        where: like(c.person_first_name, ^person_first_name)
      )

    query =
      if person_birthday != "" do
        query |> where([c], c.person_birthday == ^person_birthday)
      else
        query
      end

    Repo.all(query)
  end

  def find_organization_contacts(club_id, organization_name) do
    query =
      from(
        c in Contact,
        where: c.club_id == ^club_id,
        order_by: c.organization_name,
        where: c.type == "organization",
        where: like(c.organization_name, ^organization_name)
      )

    Repo.all(query)
  end

  @doc """
  Common filter method for contact list


  """
  def filter_contacts(club_id, name, type, role, mode \\ :all) do
    query =
      from(
        c in Contact,
        where: c.club_id == ^club_id,
        left_join: cr in assoc(c, :contact_roles),
        left_join: contract in assoc(c, :contracts),
        preload: [contact_roles: cr, contracts: contract],
        order_by: c.name
      )

    query =
      if type != "" do
        query |> where([c], like(c.type, ^type))
      else
        query
      end

    query =
      if role != "" do
        query |> where([c, cr, contract], cr.name == ^role)
      else
        query
      end

    query =
      if name != "" do
        name_search_term = "%#{name}%"
        query |> where([c], like(c.name, ^name_search_term))
      else
        query
      end

    query =
      cond do
        mode == :only_contacts ->
          query |> where([c, cr, contract], is_nil(contract.id))

        mode == :only_members ->
          query |> where([c, cr, contract], contract.id)

        mode == :all ->
          query
      end

    Repo.all(query)
  end

  def search(search_params) do
    query = Contact.Query.contact_query(search_params)

    query
    |> Repo.all()
    |> Repo.preload([
      :financial_data,
      :notes,
      :phones,
      :postal_addresses,
      :emails,
      contact_roles: [:contact_role_relations],
      contracts: [:departments, :groups]
    ])
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Gets a single contact. Preloads associations.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123, [:club])
      %Contact{}

      iex> get_contact!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id, preloads) do
    Contact
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  def create_short_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset_short_contact(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end

  def change_short_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset_short_contact(contact, attrs)
  end

  @doc """
  Returns the list of contact_groups.

  ## Examples

      iex> list_contact_groups()
      [%ContactGroup{}, ...]

  """
  def list_contact_groups(club_id) do
    query = from(cg in ContactGroup, where: cg.club_id == ^club_id)
    Repo.all(query)
  end

  @doc """
  Gets a single contact_group.

  Raises `Ecto.NoResultsError` if the Contact group does not exist.

  ## Examples

      iex> get_contact_group!(123)
      %ContactGroup{}

      iex> get_contact_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_group!(id), do: Repo.get!(ContactGroup, id)

  def get_contact_group!(id, preloads) do
    ContactGroup
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  def get_contact_group_contacts!(contact_group_id) do
    Repo.all(
      from(
        cgc in ContactGroupContact,
        where: cgc.contact_group_id == ^contact_group_id
      )
    )
  end

  @doc """
  Creates a contact_group.

  ## Examples

      iex> create_contact_group(%{field: value})
      {:ok, %ContactGroup{}}

      iex> create_contact_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_group(attrs \\ %{}) do
    %ContactGroup{}
    |> ContactGroup.changeset(attrs)
    |> Repo.insert()
  end

  def create_contact_group_contact(attrs \\ %{}) do
    %ContactGroupContact{}
    |> ContactGroupContact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact_group.

  ## Examples

      iex> update_contact_group(contact_group, %{field: new_value})
      {:ok, %ContactGroup{}}

      iex> update_contact_group(contact_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_group(%ContactGroup{} = contact_group, attrs) do
    contact_group
    |> ContactGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_group.

  ## Examples

      iex> delete_contact_group(contact_group)
      {:ok, %ContactGroup{}}

      iex> delete_contact_group(contact_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_group(%ContactGroup{} = contact_group) do
    Repo.delete(contact_group)
  end

  def delete_contact_group_contacts(contact_Ids) do
    query =
      from(
        gc in ContactGroupContact,
        where: gc.contact_id in ^contact_Ids
      )

    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_group changes.

  ## Examples

      iex> change_contact_group(contact_group)
      %Ecto.Changeset{data: %ContactGroup{}}

  """
  def change_contact_group(%ContactGroup{} = contact_group, attrs \\ %{}) do
    ContactGroup.changeset(contact_group, attrs)
  end

  alias Sportyweb.Personal.ContactRole

  @doc """
  Returns the list of contact_roles.

  ## Examples

      iex> list_contact_roles()
      [%ContactRole{}, ...]

  """
  def list_contact_roles do
    Repo.all(ContactRole)
  end

  @doc """
  Gets a single contact_role.

  Raises `Ecto.NoResultsError` if the Contact role does not exist.

  ## Examples

      iex> get_contact_role!(123)
      %ContactRole{}

      iex> get_contact_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_role!(id), do: Repo.get!(ContactRole, id)

  @doc """
  Creates a contact_role.

  ## Examples

      iex> create_contact_role(%{field: value})
      {:ok, %ContactRole{}}

      iex> create_contact_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_role(attrs \\ %{}) do
    %ContactRole{}
    |> ContactRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a role relation to a legal guradian.
  Initially creats the role with the relation when the contact does not have the role legal guardian and
  adds a relation to the present role otherwise.


  """
  def create_legal_guardian_relation(legal_guardian_contact_id, underage_contact_id, start_date) do
    query =
      from(
        cr in ContactRole,
        where: cr.contact_id == ^legal_guardian_contact_id and cr.name == "legal guardian"
      )

    legal_guradian_roles = Repo.all(query)

    if not Enum.empty?(legal_guradian_roles) and
         ContactRole.is_in_use?(List.first(legal_guradian_roles)) do
      present_role = List.first(legal_guradian_roles)

      legal_guardian_role_relation = %{
        contact_role_id: present_role.id,
        contact_id: underage_contact_id,
        valid_from: start_date
      }

      create_contact_role_relation(legal_guardian_role_relation)
    else
      legal_guardian_role = %{
        valid_from: start_date,
        name: "legal guardian",
        contact_id: legal_guardian_contact_id,
        contact_role_relations: [
          %{
            contact_id: underage_contact_id,
            valid_from: start_date
          }
        ]
      }

      create_contact_role(legal_guardian_role)
    end
  end

  @doc """
  Updates a contact_role.

  ## Examples

      iex> update_contact_role(contact_role, %{field: new_value})
      {:ok, %ContactRole{}}

      iex> update_contact_role(contact_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_role(%ContactRole{} = contact_role, attrs) do
    contact_role
    |> ContactRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_role.

  ## Examples

      iex> delete_contact_role(contact_role)
      {:ok, %ContactRole{}}

      iex> delete_contact_role(contact_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_role(%ContactRole{} = contact_role) do
    Repo.delete(contact_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_role changes.

  ## Examples

      iex> change_contact_role(contact_role)
      %Ecto.Changeset{data: %ContactRole{}}

  """
  def change_contact_role(%ContactRole{} = contact_role, attrs \\ %{}) do
    ContactRole.changeset(contact_role, attrs)
  end

  @doc """
  Saves an internally created and already validated contact to the database

  """
  def create_contact_internal(%Contact{} = contact) do
    Repo.insert(contact)
  end

  alias Sportyweb.Personal.ContactRoleRelation

  @doc """
  Returns the list of contact_role_relations.

  ## Examples

      iex> list_contact_role_relations()
      [%ContactRoleRelation{}, ...]

  """
  def list_contact_role_relations do
    Repo.all(ContactRoleRelation)
  end

  @doc """
  Gets a single contact_role_relation.

  Raises `Ecto.NoResultsError` if the Contact role relation does not exist.

  ## Examples

      iex> get_contact_role_relation!(123)
      %ContactRoleRelation{}

      iex> get_contact_role_relation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_role_relation!(id), do: Repo.get!(ContactRoleRelation, id)

  @doc """
  Creates a contact_role_relation.

  ## Examples

      iex> create_contact_role_relation(%{field: value})
      {:ok, %ContactRoleRelation{}}

      iex> create_contact_role_relation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_role_relation(attrs \\ %{}) do
    %ContactRoleRelation{}
    |> ContactRoleRelation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact_role_relation.

  ## Examples

      iex> update_contact_role_relation(contact_role_relation, %{field: new_value})
      {:ok, %ContactRoleRelation{}}

      iex> update_contact_role_relation(contact_role_relation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_role_relation(%ContactRoleRelation{} = contact_role_relation, attrs) do
    contact_role_relation
    |> ContactRoleRelation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_role_relation.

  ## Examples

      iex> delete_contact_role_relation(contact_role_relation)
      {:ok, %ContactRoleRelation{}}

      iex> delete_contact_role_relation(contact_role_relation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_role_relation(%ContactRoleRelation{} = contact_role_relation) do
    Repo.delete(contact_role_relation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_role_relation changes.

  ## Examples

      iex> change_contact_role_relation(contact_role_relation)
      %Ecto.Changeset{data: %ContactRoleRelation{}}

  """
  def change_contact_role_relation(%ContactRoleRelation{} = contact_role_relation, attrs \\ %{}) do
    ContactRoleRelation.changeset(contact_role_relation, attrs)
  end
end
