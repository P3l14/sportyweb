defmodule SportywebWeb.QualificationLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.PersonalFixtures
  import Sportyweb.AccountsFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures
  import SportywebWeb.CommonHelper
  alias Sportyweb.Personal.Qualification

  @select_dosb_attrs %{
    type: "dosb license"
  }
  @select_dosb_trainer_attrs %{
    type: "dosb license",
    dosb_license_type: "coach professional"
  }
  @create_attrs %{
    type: "dosb license",
    dosb_license_coach_sport: "Tennis",
    dosb_license_level: "C",
    dosb_license_number: "123456",
    dosb_license_number_sports_association: "123456",
    dosb_license_type: "coach professional",
    dosb_first_issuance: "2026-06-04",
    dosb_valid_until: "2056-06-04"
  }
  @update_attrs %{
    type: "dosb license",
    dosb_first_issuance: "2026-06-04",
    dosb_license_coach_sport: "Tennis",
    dosb_license_level: "C",
    dosb_license_number: "1234565",
    dosb_license_number_sports_association: "123456<",
    dosb_license_type: "coach professional",
    dosb_valid_until: "2066-06-04"
  }
  @invalid_attrs %{
    type: "dosb license",
    dosb_license_type: nil,
    dosb_license_level: nil,
    dosb_license_number: nil,
    dosb_license_number_sports_association: nil,
    dosb_first_issuance: nil,
    dosb_valid_until: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_qualification(_) do
    qualification = qualification_fixture()
    %{qualification: qualification}
  end

  describe "All" do
    setup [:create_qualification]

    test "lists all qualifications", %{conn: conn, user: user, qualification: qualification} do
      {:error, _} = live(conn, ~p"/contacts/#{qualification.contact_id}")
      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/contacts/#{qualification.contact_id}")

      assert html =~ "Qualifikationen"
      assert html =~ get_key_for_value(Qualification.get_valid_types(), qualification.type)
    end

    test "saves new qualification", %{conn: conn, user: user} do
      contact = contact_fixture()
      {:error, _} = live(conn, ~p"/contacts//#{contact}")
      conn = conn |> log_in_user(user)
      {:ok, contact_live, html} = live(conn, ~p"/contacts/#{contact}")
      assert html =~ "Bisher wurden noch keine Qualifikationen erfasst."

      new_url = ~p"/contacts/#{contact}/qualifications/new"

      {:ok, new_live, html} =
        contact_live
        |> element("a[href='#{new_url}']")
        |> render_click()
        |> follow_redirect(conn, new_url)

      assert html =~ "Qualifikation erstellen"

      # send data with selected value for type to display input fields for dosb license.
      new_live
      |> form("#qualification-form", qualification: @select_dosb_attrs)
      |> render_change()

      # Fill the form with invalid data.
      assert new_live
             |> form("#qualification-form", qualification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # send data with selected value for type to display input fields for dosb license.
      new_live
      |> form("#qualification-form", qualification: @select_dosb_attrs)
      |> render_change()

      # # send data with selected value for type to display input fields for dosb trainer.
      new_live
      |> form("#qualification-form", qualification: @select_dosb_trainer_attrs)
      |> render_change()

      {:ok, _, html} =
        new_live
        |> form("#qualification-form", qualification: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/contacts/#{contact}")

      assert html =~ "Qualifikation erfolgreich erstellt"
      assert html =~ "Trainer für Leistungssport C-Lizenz für Tennis"
    end

    test "updates qualification in listing", %{
      conn: conn,
      user: user,
      qualification: qualification
    } do
      {:error, _} = live(conn, ~p"/contacts/#{qualification.contact_id}")
      conn = conn |> log_in_user(user)
      {:ok, contact_live, _} = live(conn, ~p"/contacts/#{qualification.contact_id}")

      show_url = ~p"/contacts/#{qualification.contact_id}/qualifications/#{qualification.id}"
      edit_url = ~p"/contacts/#{qualification.contact_id}/qualifications/#{qualification.id}/edit"

      {:ok, show_live, html} =
        contact_live
        |> element("a[href='#{show_url}']", "Anzeigen")
        |> render_click()
        |> follow_redirect(conn, show_url)

      assert html =~ "Fußball"

      {:ok, edit_live, _} =
        show_live
        |> element("a[href='#{edit_url}']")
        |> render_click()
        |> follow_redirect(conn, edit_url)

      assert edit_live
             |> form("#qualification-form", qualification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      edit_live
      |> form("#qualification-form", qualification: @select_dosb_trainer_attrs)
      |> render_change()

      {:ok, _, html} =
        edit_live
        |> form("#qualification-form", qualification: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, show_url)

      assert html =~ "Tennis"
    end

    test "deletes qualification in listing", %{
      conn: conn,
      user: user,
      qualification: qualification
    } do
      {:error, _} = live(conn, ~p"/contacts/#{qualification.contact_id}")
      conn = conn |> log_in_user(user)

      {:ok, show_live, _} =
        live(conn, ~p"/contacts/#{qualification.contact_id}/qualifications/#{qualification.id}")

      edit_url = ~p"/contacts/#{qualification.contact_id}/qualifications/#{qualification.id}/edit"

      {:ok, edit_live, _} =
        show_live
        |> element("a[href='#{edit_url}']")
        |> render_click()
        |> follow_redirect(conn, edit_url)

      {:ok, _, html} =
        edit_live
        |> element("button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/contacts/#{qualification.contact_id}")

      assert html =~ "Qualifikation erfolgreich gelöscht"
      assert html =~ "Bisher wurden noch keine Qualifikationen erfasst."
    end

    test "displays qualification", %{conn: conn, user: user, qualification: qualification} do
      {:error, _} = live(conn, ~p"/contacts/#{qualification.contact_id}")
      conn = conn |> log_in_user(user)

      {:ok, _, html} =
        live(conn, ~p"/contacts/#{qualification.contact_id}/qualifications/#{qualification.id}")

      assert html =~ "Qualifikation"
      assert html =~ "DOSB Lizenz"
    end
  end
end
