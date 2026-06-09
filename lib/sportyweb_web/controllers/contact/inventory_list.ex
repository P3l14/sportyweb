defmodule SportywebWeb.ContactInventoryListController do
  use SportywebWeb, :controller

  import Ecto.Query, warn: false

  alias Sportyweb.Organization
  alias Sportyweb.Personal

  def create(conn, %{"club_id" => club_id} = parameter) do
    club = Organization.get_club!(club_id, :departments)
    year = Map.get(parameter, "member_inventory_year", Date.utc_today().year)
    date = year |> String.to_integer() |> Date.new!(1, 1)

    case Personal.can_create_member_inventory_list(club, date, "XML") do
      {:ok} ->
        inventory_document = Personal.create_member_inventory_document(club, date)

        conn
        |> put_flash(:info, "Download startet jetzt.")
        |> put_resp_content_type("application/xml")
        |> send_download({:binary, inventory_document},
          filename: "member_inventory.xml"
        )

      {:error, message} ->
        conn
        |> put_flash(
          :error,
          "Bestandsliste kann nicht erstellt werden. #{message}"
        )
        |> redirect(to: ~p"/clubs/#{club_id}/members/inventory_list")
    end
  end
end
