defmodule SportywebWeb.ContactInventoryListController do
  use SportywebWeb, :controller

  import Ecto.Query, warn: false

  alias Sportyweb.Organization
  alias Sportyweb.Personal

  def create(conn, %{"club_id" => club_id, "member_inventory_year" => year, "format" => format}) do
    club = Organization.get_club!(club_id, :departments)
    date = year |> String.to_integer() |> Date.new!(1, 1)

    case Personal.can_create_member_inventory_list(club, date, format) do
      {:ok} ->
        case format do
          "xml" ->
            inventory_document = Personal.create_member_inventory_document(club, date)

            conn
            |> put_flash(:info, "Download startet jetzt.")
            |> put_resp_content_type("application/xml")
            |> send_download({:binary, inventory_document},
              filename: "bestandserhebung_#{year}.xml"
            )

          "xslx" ->
            binary_data = Personal.create_member_inventory_document_xlsx(club, date)

            conn
            |> put_flash(:info, "Download startet jetzt.")
            |> put_resp_content_type(
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            |> send_download({:binary, binary_data},
              filename: "bestandserhebung_#{year}.xlsx"
            )
        end

      {:error, messages} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(html: SportywebWeb.ErrorHTML)
        |> render("500.html",
          from: "ContactInventoryListController",
          reason: messages |> Enum.reduce(fn message, acc -> acc <> "#{message}\n" end)
        )
    end
  end
end
