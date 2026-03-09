defmodule Mix.Tasks.Directory.Streets.Import do
  @moduledoc """
  This tasks downloads a csv file with street data used in the openplz project.
  Afterwards the file is parsed and imported in the database for further use in the postal_adress component
  """
  use Mix.Task
  alias NimbleCSV.RFC4180, as: CSV
  alias Sportyweb.Repo
  alias Sportyweb.Directory.Street

  @shortdoc "Downloads and imports streets into the database for the street proposal functionality"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    file_name = "streets.updated.csv"

    if File.exists?(file_name) do
      Mix.shell().info("File #{file_name} already present.")
    else
      Mix.shell().info("File #{file_name} not present. Start downloading...")

      csv_download_url =
        "https://raw.githubusercontent.com/openpotato/openplzapi.data/c26389b30573ab2738d0b14fd350f143aa0a1251/src/de/osm/streets.updated.csv"

      file_stream = File.stream!(file_name)
      Req.get!(csv_download_url, into: file_stream)
      Mix.shell().info("File #{file_name} successfully downloaded")
    end

    Mix.shell().info("Loading CSV file...")
    stream = File.stream!(file_name)

    headers =
      stream
      |> Enum.take(1)
      |> List.first()
      |> CSV.parse_string(skip_headers: false)
      |> List.first()
      |> Enum.map(&String.to_atom/1)

    now = DateTime.truncate(DateTime.utc_now(), :second)

    streets =
      stream
      |> CSV.parse_stream(skip_headers: true)
      |> Stream.map(fn row ->
        headers |> Enum.zip(row) |> Map.new()
      end)
      |> Enum.to_list()
      |> Enum.map(fn entry ->
        %{
          zipcode: entry[:PostalCode],
          city: entry[:Locality],
          street: String.replace(entry[:Name], "\"", ""),
          country: "DEU",
          inserted_at: now,
          updated_at: now
        }
      end)

    # All rows can not be inserted at once. So the total of over 1.000.0000 entries is chunked into batches of 10.000 items
    Mix.shell().info("CSV File loaded.")
    chunks = Enum.chunk_every(streets, 9_000)

    Mix.shell().info("Start importing into database...")

    {microseconds, rows} =
      :timer.tc(fn ->
        Enum.reduce(chunks, 0, fn batch, imported_rows ->
          {added, _} = Repo.insert_all(Street, batch)
          imported_rows + added
        end)
      end)

    Mix.shell().info("Imported #{rows} rows in #{microseconds / 1_000_000} seconds.")
  end
end
