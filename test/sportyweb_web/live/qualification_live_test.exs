defmodule SportywebWeb.QualificationLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.PersonalFixtures

  @create_attrs %{
    type: "some type",
    dosb_license_type: "some dosb_license_type",
    dosb_license_level: "some dosb_license_level",
    dosb_license_number: "some dosb_license_number",
    dosb_license_number_sports_association: "some dosb_license_number_sports_association",
    dosb_license_coach_sport: "some dosb_license_coach_sport",
    dosb_license_sport_instructor_type: "some dosb_license_sport_instructor_type",
    dosb_first_issuance: "2026-06-04",
    dosb_valid_until: "2026-06-04",
    common_type: "some common_type",
    common_description: "some common_description",
    common_issuance: "2026-06-04"
  }
  @update_attrs %{
    type: "some updated type",
    dosb_license_type: "some updated dosb_license_type",
    dosb_license_level: "some updated dosb_license_level",
    dosb_license_number: "some updated dosb_license_number",
    dosb_license_number_sports_association: "some updated dosb_license_number_sports_association",
    dosb_license_coach_sport: "some updated dosb_license_coach_sport",
    dosb_license_sport_instructor_type: "some updated dosb_license_sport_instructor_type",
    dosb_first_issuance: "2026-06-05",
    dosb_valid_until: "2026-06-05",
    common_type: "some updated common_type",
    common_description: "some updated common_description",
    common_issuance: "2026-06-05"
  }
  @invalid_attrs %{
    type: nil,
    dosb_license_type: nil,
    dosb_license_level: nil,
    dosb_license_number: nil,
    dosb_license_number_sports_association: nil,
    dosb_license_coach_sport: nil,
    dosb_license_sport_instructor_type: nil,
    dosb_first_issuance: nil,
    dosb_valid_until: nil,
    common_type: nil,
    common_description: nil,
    common_issuance: nil
  }

  defp create_qualification(_) do
    qualification = qualification_fixture()
    %{qualification: qualification}
  end

  describe "Index" do
    setup [:create_qualification]

    test "lists all qualifications", %{conn: conn, qualification: qualification} do
      {:ok, _index_live, html} = live(conn, ~p"/qualifications")

      assert html =~ "Listing Qualifications"
      assert html =~ qualification.type
    end

    test "saves new qualification", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/qualifications")

      assert index_live |> element("a", "New Qualification") |> render_click() =~
               "New Qualification"

      assert_patch(index_live, ~p"/qualifications/new")

      assert index_live
             |> form("#qualification-form", qualification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#qualification-form", qualification: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/qualifications")

      html = render(index_live)
      assert html =~ "Qualification created successfully"
      assert html =~ "some type"
    end

    test "updates qualification in listing", %{conn: conn, qualification: qualification} do
      {:ok, index_live, _html} = live(conn, ~p"/qualifications")

      assert index_live
             |> element("#qualifications-#{qualification.id} a", "Edit")
             |> render_click() =~
               "Edit Qualification"

      assert_patch(index_live, ~p"/qualifications/#{qualification}/edit")

      assert index_live
             |> form("#qualification-form", qualification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#qualification-form", qualification: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/qualifications")

      html = render(index_live)
      assert html =~ "Qualification updated successfully"
      assert html =~ "some updated type"
    end

    test "deletes qualification in listing", %{conn: conn, qualification: qualification} do
      {:ok, index_live, _html} = live(conn, ~p"/qualifications")

      assert index_live
             |> element("#qualifications-#{qualification.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#qualifications-#{qualification.id}")
    end
  end

  describe "Show" do
    setup [:create_qualification]

    test "displays qualification", %{conn: conn, qualification: qualification} do
      {:ok, _show_live, html} = live(conn, ~p"/qualifications/#{qualification}")

      assert html =~ "Show Qualification"
      assert html =~ qualification.type
    end

    test "updates qualification within modal", %{conn: conn, qualification: qualification} do
      {:ok, show_live, _html} = live(conn, ~p"/qualifications/#{qualification}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Qualification"

      assert_patch(show_live, ~p"/qualifications/#{qualification}/show/edit")

      assert show_live
             |> form("#qualification-form", qualification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#qualification-form", qualification: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/qualifications/#{qualification}")

      html = render(show_live)
      assert html =~ "Qualification updated successfully"
      assert html =~ "some updated type"
    end
  end
end
