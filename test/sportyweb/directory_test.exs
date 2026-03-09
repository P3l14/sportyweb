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

  describe "banks" do
    alias Sportyweb.Directory.Bank

    import Sportyweb.DirectoryFixtures

    @invalid_attrs %{name: nil, bankcode: nil, bic: nil, shortname: nil}

    test "list_banks/0 returns all banks" do
      bank = bank_fixture()
      assert Directory.list_banks() == [bank]
    end

    test "get_bank!/1 returns the bank with given id" do
      bank = bank_fixture()
      assert Directory.get_bank!(bank.id) == bank
    end

    test "create_bank/1 with valid data creates a bank" do
      valid_attrs = %{
        countrycode: "XX",
        name: "some name",
        bankcode: "some bankcode",
        bic: "some bic",
        shortname: "some shortname"
      }

      assert {:ok, %Bank{} = bank} = Directory.create_bank(valid_attrs)
      assert bank.countrycode == "XX"
      assert bank.name == "some name"
      assert bank.bankcode == "some bankcode"
      assert bank.bic == "some bic"
      assert bank.shortname == "some shortname"
    end

    test "create_bank/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Directory.create_bank(@invalid_attrs)
    end

    test "update_bank/2 with valid data updates the bank" do
      bank = bank_fixture()

      update_attrs = %{
        name: "some updated name",
        bankcode: "some updated bankcode",
        bic: "some updated bic",
        shortname: "some updated shortname"
      }

      assert {:ok, %Bank{} = bank} = Directory.update_bank(bank, update_attrs)
      assert bank.name == "some updated name"
      assert bank.bankcode == "some updated bankcode"
      assert bank.bic == "some updated bic"
      assert bank.shortname == "some updated shortname"
    end

    test "update_bank/2 with invalid data returns error changeset" do
      bank = bank_fixture()
      assert {:error, %Ecto.Changeset{}} = Directory.update_bank(bank, @invalid_attrs)
      assert bank == Directory.get_bank!(bank.id)
    end

    test "delete_bank/1 deletes the bank" do
      bank = bank_fixture()
      assert {:ok, %Bank{}} = Directory.delete_bank(bank)
      assert_raise Ecto.NoResultsError, fn -> Directory.get_bank!(bank.id) end
    end

    test "change_bank/1 returns a bank changeset" do
      bank = bank_fixture()
      assert %Ecto.Changeset{} = Directory.change_bank(bank)
    end

    test "get_bank_name/2 returns a bankname" do
      bank = bank_fixture()
      assert "GigaHyperMega-Bank" = Directory.get_institute("DE", "47111337")
    end

    test "get_bank_name/2 returns no bankname" do
      bank = bank_fixture()
      assert is_nil(Directory.get_institute("DE", "13374711"))
    end

    test "get_bank_name/1 returns bankname form extracted bankcode" do
      bank = bank_fixture()
      assert "GigaHyperMega-Bank" = Directory.get_institute("DE55471113370987654321")
    end

    test "get_bank_name/1 returns no bankname form extracted bankcode" do
      bank = bank_fixture()
      assert is_nil(Directory.get_institute("DE55991113370987654321"))
    end

    test "can_propose_institute/1 returns false when min length for iban is not met or country is not handled" do
      assert not Directory.can_propose_institute?("XX99123456721212")
      assert not Directory.can_propose_institute?("DE991234567")
    end

    test "can_propose_institute/1 returns true when min length for iban is met for handled country" do
      assert Directory.can_propose_institute?("DE9912345678")
      assert Directory.can_propose_institute?("DE99123456789012345")
    end

    test "check_iban/1 returns no check for iban of unhandled country" do
      assert {:no_check, ""} == Directory.check_iban("XX99123456721212")
    end

    test "check_iban/1 returns invalid for iban with wrong length for handled country" do
      assert {:invalid, "IBAN mit DE muss genau 22 Stellen haben."} ==
               Directory.check_iban("DE1888866655444433339955")
    end

    test "check_iban/1 returns invalid for iban with wrong checkdigit" do
      assert {:invalid, "Die Prüfziffer der IBAN stimmt nicht."} ==
               Directory.check_iban("DE18888666554444333399")
    end

    test "check_iban/1 returns invvalidalid for iban with correct checkdigit" do
      assert {:valid, ""} == Directory.check_iban("DE18888666554444333322")
    end
  end
end
