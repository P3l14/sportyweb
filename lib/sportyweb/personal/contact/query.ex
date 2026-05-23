defmodule Sportyweb.Personal.Contact.Query do
  import Ecto.Query, warn: false
  alias Sportyweb.Personal.Contact

  def contact_query(%{"club_id" => club_id, "type" => type} = search_params) do
    query = contact_base_query(club_id, type)

    query
    |> maybe_search_by_person_last_name(search_params["person_last_name"])
    |> maybe_search_by_person_birth_name(search_params["person_birth_name"])
    |> maybe_search_by_person_middle_names(search_params["person_middle_names"])
    |> maybe_search_by_person_first_name(search_params["person_first_name"])
    |> maybe_search_by_person_gender(search_params["person_gender"])
    |> maybe_search_by_person_birthday(search_params["person_birthday"])
    |> maybe_search_by_organization_name(search_params["organization_name"])
    |> maybe_search_by_organization_type(search_params["organization_type"])
  end

  def contact_base_query(club_id, type) do
    from(
      c in Contact,
      where: c.club_id == ^club_id,
      where: c.type == ^type,
      order_by: c.name
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
