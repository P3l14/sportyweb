defmodule Sportyweb.Personal.Contact.Query do
  import Ecto.Query, warn: false
  alias Sportyweb.Personal.Contact

  def contact_query(%{
        "type" => "contact_identification_number",
        "club_id" => club_id,
        "contact_identification_number" => identification_number
      })
      when identification_number != "" do
    from(contact in Contact,
      as: :contact,
      where: contact.club_id == ^club_id,
      where: contact.identification_number == ^identification_number
    )
  end

  def contact_query(
        %{
          "type" => "contact",
          "club_id" => club_id,
          "contact" => %{"type" => type} = contact_params
        } = scope_params
      ) do
    query = contact_base_query(club_id, type)

    query
    |> apply_search_scope(scope_params["search_scope"], scope_params["include_invalid"])
    |> maybe_search_by_person_last_name(contact_params["person_last_name"])
    |> maybe_search_by_person_birth_name(contact_params["person_birth_name"])
    |> maybe_search_by_person_middle_names(contact_params["person_middle_names"])
    |> maybe_search_by_person_first_name(contact_params["person_first_name"])
    |> maybe_search_by_person_gender(contact_params["person_gender"])
    |> maybe_search_by_person_birthday(contact_params["person_birthday"])
    |> maybe_search_by_organization_name(contact_params["organization_name"])
    |> maybe_search_by_organization_type(contact_params["organization_type"])
    |> order_by_name()
  end

  def order_by_name(query)

  def order_by_name(%Ecto.Query{distinct: nil} = query) do
    query |> order_by([contact: contact], contact.name)
  end

  def order_by_name(%Ecto.Query{distinct: _} = query) do
    # using subquery because order by works not on [distinct queries](https://ecto.hexdocs.pm/Ecto.Query.html#distinct/3). When distinct is used a group by claus for the same column is added at the frist place.
    from(contact in subquery(query),
      order_by: contact.name
    )
  end

  @doc """
  Scope determinse the set of contacts on which the search is performed:
  * all
  * only_members
  * without_members
  include_invalid decides wheter or not the contact role or the contract ist valid today



  """
  def apply_search_scope(query, search_scope, include_invalid)

  def apply_search_scope(query, "all", "true") do
    query
  end

  def apply_search_scope(query, "all", "false") do
    date = Date.utc_today()

    from([contact: contact] in query,
      left_join: contact_role in assoc(contact, :contact_roles),
      left_join: contract in assoc(contact, :contracts),
      where:
        (not is_nil(contract) and contract.start_date <= ^date and
           (is_nil(contract.archive_date) or contract.archive_date >= ^date)) or
          (not is_nil(contact_role) and contact_role.valid_from <= ^date and
             (is_nil(contact_role.valid_until) or contact_role.valid_until >= ^date))
    )
  end

  def apply_search_scope(query, "without_members", "true") do
    from([contact: contact] in query,
      inner_join: contact_role in assoc(contact, :contact_roles),
      left_join: contract in assoc(contact, :contracts),
      where: is_nil(contract)
    )
  end

  def apply_search_scope(query, "without_members", "false") do
    date = Date.utc_today()

    from([contact: contact] in query,
      left_join: contact_role in assoc(contact, :contact_roles),
      left_join: contract in assoc(contact, :contracts),
      where:
        is_nil(contract) and not is_nil(contact_role) and contact_role.valid_from <= ^date and
          (is_nil(contact_role.valid_until) or contact_role.valid_until >= ^date)
    )
  end

  def apply_search_scope(query, "only_members", "true") do
    from([contact: contact] in query,
      inner_join: contract in assoc(contact, :contracts)
    )
  end

  def apply_search_scope(query, "only_members", "false") do
    date = Date.utc_today()

    from([contact: contact] in query,
      left_join: contract in assoc(contact, :contracts),
      where:
        not is_nil(contract) and contract.start_date <= ^date and
          (is_nil(contract.archive_date) or contract.archive_date >= ^date)
    )
  end

  def contact_base_query(club_id, type) do
    from(
      c in Contact,
      as: :contact,
      distinct: c.id,
      where: c.club_id == ^club_id,
      where: c.type == ^type
    )
  end

  def maybe_search_by_person_last_name(query, person_last_name)
      when person_last_name not in ["", nil] do
    query |> where([c], like(c.person_last_name, ^person_last_name))
  end

  def maybe_search_by_person_last_name(query, _) do
    query
  end

  def maybe_search_by_person_birth_name(query, person_birth_name)
      when person_birth_name not in ["", nil] do
    query |> where([c], like(c.person_birth_name, ^person_birth_name))
  end

  def maybe_search_by_person_birth_name(query, _) do
    query
  end

  def maybe_search_by_person_birthday(query, person_birthday)
      when person_birthday not in ["", nil] do
    query |> where([c], c.person_birthday == ^person_birthday)
  end

  def maybe_search_by_person_birthday(query, _) do
    query
  end

  def maybe_search_by_person_gender(query, person_gender) when person_gender not in ["", nil] do
    query |> where([c], c.person_gender == ^person_gender)
  end

  def maybe_search_by_person_gender(query, _) do
    query
  end

  def maybe_search_by_person_middle_names(query, person_middle_names)
      when person_middle_names not in ["", nil] do
    query |> where([c], like(c.person_middle_names, ^person_middle_names))
  end

  def maybe_search_by_person_middle_names(query, _) do
    query
  end

  def maybe_search_by_person_first_name(query, person_first_name)
      when person_first_name not in ["", nil] do
    query |> where([c], like(c.person_first_name, ^person_first_name))
  end

  def maybe_search_by_person_first_name(query, _) do
    query
  end

  def maybe_search_by_organization_name(query, organization_name)
      when organization_name not in ["", nil] do
    query |> where([c], like(c.organization_name, ^organization_name))
  end

  def maybe_search_by_organization_name(query, _) do
    query
  end

  def maybe_search_by_organization_type(query, organization_type)
      when organization_type not in ["", nil] do
    query |> where([c], like(c.organization_type, ^organization_type))
  end

  def maybe_search_by_organization_type(query, _) do
    query
  end
end
