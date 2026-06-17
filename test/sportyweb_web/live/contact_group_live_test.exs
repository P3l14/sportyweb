defmodule SportywebWeb.ContactGroupLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.PersonalFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @invalid_attrs %{
    contact_group: %{
      name: "",
      type: "family"
    }
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_contact_group(_) do
    contact_group = contact_group_fixture()
    contact = contact_fixture(club_id: contact_group.club_id)

    contact_group_contact =
      contact_group_contact_fixture(contact_group_id: contact_group.id, contact_id: contact.id)

    contact_group2 = contact_group_fixture(name: "Familie Müller", club_id: contact_group.club_id)

    contact_group_contact_fixture(
      contact_group_id: contact_group2.id,
      contact_id: contact_fixture(club_id: contact_group.club_id).id
    )

    contact_group_contact_fixture(
      contact_group_id: contact_group2.id,
      contact_id: contact_fixture(club_id: contact_group.club_id).id
    )

    %{
      contact_group: contact_group,
      contact_group2: contact_group2,
      contact_group_contact: contact_group_contact
    }
  end

  describe "Index" do
    setup [:create_contact_group]

    test "lists all contacts", %{conn: conn, user: user, contact_group: contact_group} do
      url = ~p"/clubs/#{contact_group.club_id}/contact_groups"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, url)

      assert html =~ "Kontaktgruppen"
      assert html =~ contact_group.name
    end
  end

  describe "New/Edit" do
    setup [:create_contact_group]

    test "saves new contact", %{conn: conn, user: user, contact_group: contact_group} do
      c1 = contact_fixture(club_id: contact_group.club_id)
      c2 = contact_fixture(club_id: contact_group.club_id)
      url = ~p"/clubs/#{contact_group.club_id}/contact_groups/new"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, url)

      assert html =~ "Kontaktgruppe erstellen"

      # Fill the form with data.
      assert new_live
             |> form("#contact_group-form", contact_group_form: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # Attempts to use the add button to add a new entry does not work. Passing the data in form does not work as well. Use render_change instead.
      # new_live
      # |> element("button[value=\"new\"]")
      # |> render_click()
      # |> render_change()
      new_live
      |> element("#contact_group-form")
      |> render_change(%{
        contact_group_form: %{
          contacts_sort: ["0", "new"]
        }
      })

      {:ok, _, html} =
        new_live
        |> form("#contact_group-form",
          contact_group_form: %{
            contact_group: %{
              type: "family",
              name: "Brown"
            },
            contact_group_contacts: %{
              "0" => %{
                contact_id: c1.id
              },
              "1" => %{
                contact_id: c2.id
              }
            }
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{contact_group.club_id}/contact_groups")

      assert html =~ "Kontaktgruppe erfolgreich erstellt"
      assert html =~ "Brown"
    end

    test "cancels save new contact", %{conn: conn, user: user, contact_group: contact_group} do
      url = ~p"/clubs/#{contact_group.club_id}/contact_groups/new"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, new_live, _} = live(conn, url)

      {:ok, _, _html} =
        new_live
        |> element("#contact_group-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{contact_group.club_id}/contact_groups")
    end

    test "updates contact group", %{
      conn: conn,
      user: user,
      contact_group: contact_group,
      contact_group_contact: contact_group_contact
    } do
      url = ~p"/contact_groups/#{contact_group.id}/edit"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, url)

      assert html =~ "Kontaktgruppe bearbeiten"

      assert edit_live
             |> form("#contact_group-form", contact_group_form: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#contact_group-form",
          contact_group_form: %{
            contact_group: %{
              type: "family",
              name: "Green"
            },
            contact_group_contacts: %{
              "0" => %{
                contact_id: contact_group_contact.contact_id
              }
            }
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/contact_groups/#{contact_group.id}")

      assert html =~ "Kontaktgruppe erfolgreich aktualisiert"
      assert html =~ "Green"
    end

    test "updates contact group / failure due addong the same contact twice to the same group", %{
      conn: conn,
      user: user,
      contact_group2: contact_group
    } do
      contact = contact_fixture(club_id: contact_group.club_id)
      url = ~p"/contact_groups/#{contact_group.id}/edit"
      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, url)

      assert html =~ "Kontaktgruppe bearbeiten"

      html =
        edit_live
        |> form("#contact_group-form",
          contact_group_form: %{
            contact_group: %{
              type: "family",
              name: "Blue"
            },
            contact_group_contacts: %{
              "0" => %{
                contact_id: contact.id
              },
              "1" => %{
                contact_id: contact.id
              }
            }
          }
        )
        |> render_submit()

      assert html =~
               "Der gleiche Kontakt darf nicht zwei Mal der gleichen Kontaktgruppe hinzugefügt werden!"
    end

    test "updates contact group / change", %{
      conn: conn,
      user: user,
      contact_group2: contact_group
    } do
      contact = contact_fixture(club_id: contact_group.club_id)
      contact2 = contact_fixture(club_id: contact_group.club_id)
      url = ~p"/contact_groups/#{contact_group.id}/edit"
      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, url)

      assert html =~ "Kontaktgruppe bearbeiten"

      {:ok, _, html} =
        edit_live
        |> form("#contact_group-form",
          contact_group_form: %{
            contact_group: %{
              type: "family",
              name: "Blue"
            },
            contact_group_contacts: %{
              "0" => %{
                contact_id: contact.id
              },
              "1" => %{
                contact_id: contact2.id
              }
            }
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/contact_groups/#{contact_group.id}")

      assert html =~ "Kontaktgruppe erfolgreich aktualisiert"
      assert html =~ "Blue"
    end

    test "cancels updates contact group", %{conn: conn, user: user, contact_group: contact_group} do
      url = ~p"/contact_groups/#{contact_group.id}/edit"
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _} = live(conn, url)

      {:ok, _, _html} =
        edit_live
        |> element("#contact_group-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/contact_groups/#{contact_group.id}")
    end

    test "deletes contact", %{conn: conn, user: user, contact_group: contact_group} do
      url = ~p"/contact_groups/#{contact_group.id}/edit"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, url)
      assert html =~ contact_group.name

      {:ok, _, html} =
        edit_live
        |> element("#contact_group-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{contact_group.club_id}/contact_groups")

      assert html =~ "Kontaktgruppe erfolgreich gelöscht"
      assert html =~ "Kontaktgruppen"
      refute html =~ contact_group.name
    end
  end

  describe "Show" do
    setup [:create_contact_group]

    test "displays contact group", %{conn: conn, user: user, contact_group: contact_group} do
      url = ~p"/contact_groups/#{contact_group.id}"
      {:error, _} = live(conn, url)

      conn = conn |> log_in_user(user)
      {:ok, _, html} = live(conn, url)

      assert html =~ "Kontaktgruppe:"
      assert html =~ contact_group.name
    end
  end
end
