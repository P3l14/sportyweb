defmodule Sportyweb.Personal do
  @moduledoc """
  The Personal context.
  """

  import Ecto.Query, warn: false
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
  def list_contract_contact_options(contract, contract_object) do
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
        where: c.club_id == ^contract.club_id,
        where: c.id not in ^exclude_contact_ids,
        order_by: c.name
      )

    Repo.all(query)
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

  alias Sportyweb.Personal.ContactGroup

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

  def create_contact_group_for_form(attrs \\ %{}) do
    contact_group_cs =
      %ContactGroup{}
      |> ContactGroup.changeset(attrs)

    {:ok, contact_group} = Repo.insert(contact_group_cs)

    attrs
    |> Map.get("contacts")
    |> Map.values()
    |> Enum.map(fn contact ->
      Enum.into(contact, %{
        "contact_group_id" => contact_group.id,
        "contact_id" => Map.get(contact, "id")
      })
    end)
    |> Enum.each(fn contact ->
      %ContactGroupContact{}
      |> ContactGroupContact.changeset(contact)
      |> Repo.insert()
    end)
  end

  def create_contact_group_for_form2(attrs \\ %{}) do
    %ContactGroup{}
    |> ContactGroup.changeset(attrs)
    |> Repo.insert()
  end

  def create_contact_group_contacts(attrs \\ %{}) do
    %ContactGroupContact{}
    |> ContactGroupContact.changeset(attrs)
    |> Repo.insert()
  end

  def create_contact_group_for_form3(attrs \\ %{}) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :contact_group,
        %ContactGroup{}
        |> ContactGroup.changeset(attrs)
      )

    multi =
      attrs
      |> Map.get("contacts")
      |> Map.values()
      |> Enum.reduce(multi, fn contact, acc_multi ->
        Ecto.Multi.insert(acc_multi, {:contact_group_contact, Map.get(contact, "id")}, fn %{
                                                                                            contact_group:
                                                                                              contact_group
                                                                                          } ->
          %ContactGroupContact{}
          |> ContactGroupContact.changeset(%{
            contact_group_id: contact_group.id,
            contact_id: Map.get(contact, "id")
          })
        end)
      end)

    Repo.transaction(multi)
  end

  def create_contact_group_for_form4(attrs \\ %{}) do
    Repo.transaction(fn ->
      contact_group_cs =
        %ContactGroup{}
        |> ContactGroup.changeset(attrs)

      contact_group = Repo.insert!(contact_group_cs)

      attrs
      |> Map.get("contacts")
      |> Map.values()
      |> Enum.map(fn contact ->
        Enum.into(contact, %{
          "contact_group_id" => contact_group.id,
          "contact_id" => Map.get(contact, "id")
        })
      end)
      |> Enum.each(fn contact ->
        %ContactGroupContact{}
        |> ContactGroupContact.changeset(contact)
        |> Repo.insert!()
      end)
    end)
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

  def update_contact_group_contacts(%ContactGroup{} = contact_group, attrs) do
    contact_group |> ContactGroup.changeset_for_form(attrs) |> Repo.update()
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

  def change_contact_group_for_form(%ContactGroup{} = contact_group, attrs \\ %{}) do
    ContactGroup.changeset_for_form(contact_group, attrs)
  end
end
