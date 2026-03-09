defmodule Sportyweb.DirectoryTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Directory

  describe "streets" do
    alias Sportyweb.Directory.Street

    import Sportyweb.DirectoryFixtures

    @invalid_attrs %{zipcode: nil, city: nil, street: nil}

    test "list_streets/0 returns all streets" do
      street = street_fixture()
      assert Directory.list_streets() == [street]
    end

    test "get_street!/1 returns the street with given id" do
      street = street_fixture()
      assert Directory.get_street!(street.id) == street
    end

    test "create_street/1 with valid data creates a street" do
      valid_attrs = %{
        country: "some country",
        zipcode: "some zipcode",
        city: "some city",
        street: "some street"
      }

      assert {:ok, %Street{} = street} = Directory.create_street(valid_attrs)
      assert street.country == "some country"
      assert street.zipcode == "some zipcode"
      assert street.city == "some city"
      assert street.street == "some street"
    end

    test "create_street/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Directory.create_street(@invalid_attrs)
    end

    test "update_street/2 with valid data updates the street" do
      street = street_fixture()

      update_attrs = %{
        zipcode: "some updated zipcode",
        city: "some updated city",
        street: "some updated street"
      }

      assert {:ok, %Street{} = street} = Directory.update_street(street, update_attrs)
      assert street.zipcode == "some updated zipcode"
      assert street.city == "some updated city"
      assert street.street == "some updated street"
    end

    test "update_street/2 with invalid data returns error changeset" do
      street = street_fixture()
      assert {:error, %Ecto.Changeset{}} = Directory.update_street(street, @invalid_attrs)
      assert street == Directory.get_street!(street.id)
    end

    test "delete_street/1 deletes the street" do
      street = street_fixture()
      assert {:ok, %Street{}} = Directory.delete_street(street)
      assert_raise Ecto.NoResultsError, fn -> Directory.get_street!(street.id) end
    end

    test "change_street/1 returns a street changeset" do
      street = street_fixture()
      assert %Ecto.Changeset{} = Directory.change_street(street)
    end

    test "get_zipcodes/1 returns zipcodes for country" do
      assert [] == Directory.get_zipcodes("DEU")

      street_fixture(%{
        country: "DEU",
        zipcode: "47117",
        city: "Musterstadt"
      })

      assert 1 == length(Directory.get_zipcodes("DEU"))
      assert [["47117", "Musterstadt"]] == Directory.get_zipcodes("DEU")
      assert [] == Directory.get_zipcodes("AUT")
    end

    test "get_zipcodes/2 returns only zipcodes which starts with passed zipcode fragment" do
      street_fixture(%{
        country: "DEU",
        zipcode: "47117",
        city: "Bilderstadt"
      })

      street_fixture(%{
        country: "DEU",
        zipcode: "57117",
        city: "Musterstadt"
      })

      street_fixture(%{
        country: "DEU",
        zipcode: "57217",
        city: "Blumenstadt"
      })

      assert [] == Directory.get_zipcodes("DEU", "2")
      assert 1 == length(Directory.get_zipcodes("DEU", "4"))
      assert 2 == length(Directory.get_zipcodes("DEU", "5"))
    end

    test "get_streets/2" do
      street_fixture(%{
        country: "DEU",
        zipcode: "47117",
        city: "Bilderstadt",
        street: "Hauptstraße"
      })

      street_fixture(%{
        country: "DEU",
        zipcode: "47117",
        city: "Bilderstadt",
        street: "Seitenstraße"
      })

      assert [] == Directory.get_zipcodes("DEU", "57117")
      assert 2 == length(Directory.get_streets("DEU", "47117"))
      assert ["Hauptstraße", "Seitenstraße"] == Directory.get_streets("DEU", "47117")
    end
  end
end
