defmodule Sportyweb.DirectoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Directory` context.
  """

  @doc """
  Generate a street.
  """
  def street_fixture(attrs \\ %{}) do
    {:ok, street} =
      attrs
      |> Enum.into(%{
        country: "DEU",
        city: "Musterstadt",
        street: "Irgendwo",
        zipcode: "47117"
      })
      |> Sportyweb.Directory.create_street()

    street
  end

  @doc """
  Generate a bank.
  """
  def bank_fixture(attrs \\ %{}) do
    {:ok, bank} =
      attrs
      |> Enum.into(%{
        countrycode: "DE",
        bankcode: "47111337",
        bic: "GIGABANK",
        name: "GigaHyperMega-Bank",
        shortname: "GHM-Bank"
      })
      |> Sportyweb.Directory.create_bank()

    bank
  end
end
