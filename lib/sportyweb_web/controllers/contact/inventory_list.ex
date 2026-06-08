defmodule SportywebWeb.ContactInventoryListController do
  use SportywebWeb, :controller

  import Ecto.Query, warn: false
  import XmlBuilder
  alias Sportyweb.Repo

  alias Sportyweb.Organization
  alias Sportyweb.Personal.Contact

  def create(conn, %{"club_id" => club_id} = parameter) do
    club = Organization.get_club!(club_id, :departments)

    if club.association_number == "" do
      conn
      |> put_flash(
        :error,
        "Bestandsliste kann nicht erstellt werden. Beim Verein ist nicht die vom Landessportbund vergebene Vereinsnummer gespeichert!"
      )
      |> redirect(to: ~p"/clubs/#{club}/members")
    else
      year = Map.get(parameter, "member_inventory_year", Date.utc_today().year)
      date = year |> String.to_integer() |> Date.new!(1, 1)

      # Query for type a inventory. Based on the assumption that every member needs a club contract and there can't be a department contract without a club contract.

      Repo.all(
        from(
          c in Contact,
          inner_join: contract in assoc(c, :contracts),
          inner_join: club_contract in assoc(contract, :clubs),
          where: c.club_id == ^club_id,
          where: c.type == "person",
          where:
            contract.start_date <= ^date and
              (is_nil(contract.archive_date) or contract.archive_date >= ^date),
          preload: :contracts
        )
      )

      query =
        from(
          c in Contact,
          inner_join: contract in assoc(c, :contracts),
          inner_join: club_contract in assoc(contract, :clubs),
          where: c.club_id == ^club_id,
          where: c.type == "person",
          where:
            contract.start_date <= ^date and
              (is_nil(contract.archive_date) or contract.archive_date >= ^date),
          group_by: [fragment("EXTRACT(YEAR FROM ?)", c.person_birthday), c.person_gender],
          select: %{
            year: fragment("EXTRACT(YEAR FROM ?)", c.person_birthday),
            gender: c.person_gender,
            count: count(c.id)
          }
        )

      inventory_a = Repo.all(query)

      inventory_a_grouped_by_year_and_gender =
        Enum.group_by(inventory_a, fn map -> map.year end)
        |> Map.new(fn {year, maps} ->
          grouped_by_gender =
            maps
            |> Enum.group_by(fn map -> map.gender end)
            |> Map.new(fn {key, [head | _tail]} -> {key, head} end)

          {year, grouped_by_gender}
        end)

      inventory_b_grouped_by_year_and_gender =
        if inventory_a_grouped_by_year_and_gender != %{} and club.departments == [] and
             club.association_number do
          %{club.association_number => inventory_a_grouped_by_year_and_gender}
        else
          %{}
        end

      inventory_document =
        document(
          element(:Mitglieder, [
            element(:Software, [
              element(:Schluessel, "Sportyweb")
            ]),
            element(:Verein, [
              element(:Nummer, club.association_number),
              element(:Bezeichnung, club.name),
              element(:Ansprechpartner, "Eine Person...")
            ]),
            Enum.map(inventory_a_grouped_by_year_and_gender, fn {year, gender_map} ->
              element(:Zahlen, [
                element(:Typ, "A"),
                element(:Fachverband, ""),
                element(:Jahrgang, Decimal.to_integer(year)),
                element(:AnzahlW, Map.get(Map.get(gender_map, "female", %{}), :count, 0)),
                element(:AnzahlD, Map.get(Map.get(gender_map, "other", %{}), :count, 0)),
                element(:AnzahlM, Map.get(Map.get(gender_map, "male", %{}), :count, 0)),
                element(:AnzahlO, Map.get(Map.get(gender_map, "no_info", %{}), :count, 0))
              ])
            end),
            Enum.map(inventory_b_grouped_by_year_and_gender, fn {association_number,
                                                                 year_gender_map} ->
              Enum.map(year_gender_map, fn {year, gender_map} ->
                element(:Zahlen, [
                  element(:Typ, "B"),
                  element(:Fachverband, association_number),
                  element(:Jahrgang, Decimal.to_integer(year)),
                  element(:AnzahlW, Map.get(Map.get(gender_map, "female", %{}), :count, 0)),
                  element(:AnzahlD, Map.get(Map.get(gender_map, "other", %{}), :count, 0)),
                  element(:AnzahlM, Map.get(Map.get(gender_map, "male", %{}), :count, 0)),
                  element(:AnzahlO, Map.get(Map.get(gender_map, "no_info", %{}), :count, 0))
                ])
              end)
            end)
          ])
        )

      #     <?xml version="1.0" encoding="utf-8" ?>
      #   <Mitglieder>
      # 	<Software>
      # 		<Schluessel>ABCDEFGHIJ1234567890</Schluessel>
      # 	</Software>
      # 	<Verein>
      # 		<Nummer>123456</Nummer>
      # 		<Bezeichnung>Sportverein Berlin e.V.</Bezeichnung>
      # 		<Ansprechpartner>Kai Müller</Ansprechpartner>
      # 	</Verein>
      # 	<Zahlen>
      # 		<Typ>A</Typ>
      # 		<Fachverband/>
      # 		<Jahrgang>1972</Jahrgang>
      # 		<AnzahlM>234</AnzahlM>
      # 		<AnzahlW>132</AnzahlW>
      # 		<AnzahlD>1</AnzahlD>
      # 		<AnzahlO>0</AnzahlO>
      # 	</Zahlen>
      # 	<Zahlen>
      # 		<Typ>A</Typ>
      # 		<Fachverband/>
      # 		<Jahrgang>1988</Jahrgang>
      # 		<AnzahlM>78</AnzahlM>
      # 		<AnzahlW>103</AnzahlW>
      # 		<AnzahlD>0</AnzahlD>
      # 		<AnzahlO>1</AnzahlO>
      # 	</Zahlen>
      # 	<Zahlen>
      # 		<Typ>B</Typ>
      # 		<Fachverband>12</Fachverband>
      # 		<Jahrgang>1972</Jahrgang>
      # 		<AnzahlM>12</AnzahlM>
      # 		<AnzahlW>6</AnzahlW>
      # 		<AnzahlD>0</AnzahlD>
      # 		<AnzahlO>0</AnzahlO>
      # 	</Zahlen>
      # 	<Zahlen>
      # 		<Typ>B</Typ>
      # 		<Fachverband>12</Fachverband>
      # 		<Jahrgang>1988</Jahrgang>
      # 		<AnzahlM>7</AnzahlM>
      # 		<AnzahlW>13</AnzahlW>
      # 		<AnzahlD>1</AnzahlD>
      # 		<AnzahlO>0</AnzahlO>
      # 	</Zahlen>
      # </Mitglieder>

      conn
      |> put_flash(:info, "Download startet jetzt.")
      |> put_resp_content_type("application/xml")
      |> send_download({:binary, inventory_document |> generate},
        filename: "member_inventory.xml"
      )
    end
  end
end
