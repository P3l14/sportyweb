defmodule SportywebWeb.SearchLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PersonalFixtures
  import Sportyweb.LegalFixtures
  import Sportyweb.FinanceFixtures
  import Sportyweb.AccountsFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_contacts(_) do
    club = club_fixture()
    fee = fee_fixture()
    club_id = club.id

    contact1 =
      contact_with_contract_fixture(%{
        club_id: club_id,
        person_last_name: "Mustermann",
        person_birth_name: "Muster",
        person_middle_names: "Marius Markus",
        person_first_name: "Max",
        person_birthday: ~D[1986-09-01],
        person_gender: "no_info",
        contact_roles: [
          %{valid_from: Date.add(Date.utc_today(), -2 * 365), name: "interested"}
        ],
        fee_contract_target_object_list: [%{fee: fee, contract_target_object: club}]
      })

    contract_fixture()

    contact2 =
      contact_fixture(%{
        club_id: club_id,
        person_last_name: "Mustermann",
        person_first_name: "Maria"
      })

    %{club: club, contact1: contact1, contact2: contact2}
  end

  describe "search" do
    setup [:create_contacts]

    test "search by contact_identification_number", %{
      conn: conn,
      user: user,
      club: club,
      contact1: contact1
    } do
      search_url = ~p"/clubs/#{club}/contacts/search"
      {:error, _} = live(conn, search_url)
      conn = conn |> log_in_user(user)
      {:ok, search_live, html} = live(conn, search_url)

      assert html =~ "Kontaktsuche"

      assert search_live
             |> form("#search-form", %{})
             |> render_submit() =~ "Bitte wählen Sie eine Suchart aus."

      assert search_live
             |> form("#search-form", %{search_form: %{type: "contact_identification_number"}})
             |> render_change()

      assert search_live
             |> form("#search-form", %{
               search_form: %{
                 type: "contact_identification_number",
                 contact_identification_number: 47_114_711
               }
             })
             |> render_change() =~
               "Die Prüfziffer der Kontaktnummer stimmt nicht. Bitte überprüfen Sie Ihre Eingabe."

      assert search_live
             |> form("#search-form", %{
               search_form: %{
                 type: "contact_identification_number",
                 contact_identification_number: contact1.identification_number
               }
             })
             |> render_submit() =~ contact1.name
    end

    test "search by contact conctact", %{conn: conn, user: user, club: club, contact1: contact1} do
      search_url = ~p"/clubs/#{club}/contacts/search"
      {:error, _} = live(conn, search_url)
      conn = conn |> log_in_user(user)
      {:ok, search_live, html} = live(conn, search_url)

      assert html =~ "Kontaktsuche"

      assert search_live
             |> form("#search-form", %{search_form: %{type: "contact"}})
             |> render_change()

      assert search_live
             |> form("#search-form", %{
               search_form: %{
                 type: "contact",
                 include_invalid: "false",
                 contact: %{
                   type: "person"
                 }
               }
             })
             |> render_submit() =~ contact1.name
    end

    test "search reset button", %{
      conn: conn,
      user: user,
      club: club
    } do
      search_url = ~p"/clubs/#{club}/contacts/search"
      {:error, _} = live(conn, search_url)
      conn = conn |> log_in_user(user)
      {:ok, search_live, html} = live(conn, search_url)

      assert html =~ "Kontaktsuche"

      assert search_live
             |> form("#search-form", %{search_form: %{type: "contact_identification_number"}})
             # included \n</label> because "Kontaktnummer" is included in the type selection
             |> render_change() =~ "Kontaktnummer\n</label>"

      {:ok, _, html} =
        search_live
        |> element("button", "Filter zurücksetzen")
        |> render_click()
        |> follow_redirect(conn, search_url)

      assert html =~ "Kontaktsuche"
      # included \n</label> because "Kontaktnummer" is included in the type selection
      refute html =~ "Kontaktnummer\n</label>"
    end
  end
end
