defmodule Mix.Tasks.Directory.Banks.Import do
  @moduledoc """
  This tasks downloads a csv file with german bank data used provided by the Bundesbank.
  Afterwards the file is parsed and imported in the database for further use in the financial_data component
  """
  use Mix.Task
  alias Sportyweb.Repo
  alias Sportyweb.Directory.Bank
  alias Mix.Tasks.Directory.Banks.BankCSVParser

  @shortdoc "Downloads und imports data about banknames and bank code numbers"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    file_name = "blz-aktuell-csv-data.csv"

    if File.exists?(file_name) do
      Mix.shell().info("File #{file_name} already present.")
    else
      Mix.shell().info("File #{file_name} not present. Start downloading...")

      csv_download_url =
        "https://www.bundesbank.de/resource/blob/926192/0747aff499cd9f6f4c14d625fd7c643c/472B63F073F071307366337C94F8C870/blz-aktuell-csv-data.csv"

      file_stream = File.stream!(file_name, encoding: :ansi)
      Req.get!(csv_download_url, into: file_stream)
      Mix.shell().info("File #{file_name} successfully downloaded")
    end

    Mix.shell().info("Loading CSV file...")
    stream = File.stream!(file_name, [:read, :binary, encoding: :latin1])

    headers =
      stream
      |> Enum.take(1)
      |> List.first()
      |> BankCSVParser.parse_string(skip_headers: false)
      |> List.first()
      |> Enum.map(&String.to_atom/1)

    now = DateTime.truncate(DateTime.utc_now(), :second)

    banks =
      stream
      |> BankCSVParser.parse_stream(skip_headers: true)
      |> Stream.map(fn row ->
        headers |> Enum.zip(row) |> Map.new()
      end)
      |> Enum.to_list()
      |> Enum.map(fn entry ->
        %{
          name: entry[:Bezeichnung],
          countrycode: "DE",
          bankcode: entry[:Bankleitzahl],
          bic: entry[:BIC],
          shortname: entry[:Kurzbezeichnung],
          inserted_at: now,
          updated_at: now
        }
      end)

    # All rows can not be inserted at once. So the total of over 1.000.0000 entries is chunked into batches of 10.000 items
    Mix.shell().info("CSV File loaded.")
    chunks = Enum.chunk_every(banks, 8_000)

    Mix.shell().info("Start importing into database...")

    {microseconds, rows} =
      :timer.tc(fn ->
        Enum.reduce(chunks, 0, fn batch, imported_rows ->
          {added, _} = Repo.insert_all(Bank, batch)
          imported_rows + added
        end)
      end)

    Mix.shell().info("Imported #{rows} rows in #{microseconds / 1_000_000} seconds.")
  end
end
