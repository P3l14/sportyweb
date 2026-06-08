defmodule SportywebWeb.ContactInventoryListController do
  use SportywebWeb, :controller

  import Ecto.Query, warn: false

  alias Sportyweb.Organization
  alias Sportyweb.Personal

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
      inventory_document = Personal.create_member_inventory_document(club, date)

      conn
      |> put_flash(:info, "Download startet jetzt.")
      |> put_resp_content_type("application/xml")
      |> send_download({:binary, inventory_document},
        filename: "member_inventory.xml"
      )
    end
  end
end
