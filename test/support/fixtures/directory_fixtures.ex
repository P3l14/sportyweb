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
end
