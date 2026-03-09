defmodule Sportyweb.Directory do
  @moduledoc """
  The Directory context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Directory.Street

  @doc """
  Returns the list of streets.

  ## Examples

      iex> list_streets()
      [%Street{}, ...]

  """
  def list_streets do
    Repo.all(Street)
  end

  @doc """
  Gets a single street.

  Raises `Ecto.NoResultsError` if the Street does not exist.

  ## Examples

      iex> get_street!(123)
      %Street{}

      iex> get_street!(456)
      ** (Ecto.NoResultsError)

  """
  def get_street!(id), do: Repo.get!(Street, id)

  @doc """
  Creates a street.

  ## Examples

      iex> create_street(%{field: value})
      {:ok, %Street{}}

      iex> create_street(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_street(attrs \\ %{}) do
    %Street{}
    |> Street.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a street.

  ## Examples

      iex> update_street(street, %{field: new_value})
      {:ok, %Street{}}

      iex> update_street(street, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_street(%Street{} = street, attrs) do
    street
    |> Street.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a street.

  ## Examples

      iex> delete_street(street)
      {:ok, %Street{}}

      iex> delete_street(street)
      {:error, %Ecto.Changeset{}}

  """
  def delete_street(%Street{} = street) do
    Repo.delete(street)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking street changes.

  ## Examples

      iex> change_street(street)
      %Ecto.Changeset{data: %Street{}}

  """
  def change_street(%Street{} = street, attrs \\ %{}) do
    Street.changeset(street, attrs)
  end

  def get_zipcodes(country) do
    Repo.all(
      from(
        s in Street,
        where: s.country == ^country,
        select: [s.zipcode, s.city],
        distinct: s.zipcode,
        order_by: s.zipcode
      )
    )
  end

  def get_zipcodes(country, zipcode_fragment) do
    Repo.all(
      from(
        s in Street,
        where: like(s.zipcode, ^"#{zipcode_fragment}%") and s.country == ^country,
        select: [s.zipcode, s.city],
        distinct: s.zipcode,
        order_by: s.zipcode
      )
    )
  end

  def get_streets(country, zipcode) do
    Repo.all(
      from(
        s in Street,
        where: s.country == ^country and s.zipcode == ^zipcode,
        select: s.street,
        distinct: s.street,
        order_by: s.street
      )
    )
  end

  alias Sportyweb.Directory.Bank

  @doc """
  Returns the list of banks.

  ## Examples

      iex> list_banks()
      [%Bank{}, ...]

  """
  def list_banks do
    Repo.all(Bank)
  end

  @doc """
  Gets a single bank.

  Raises `Ecto.NoResultsError` if the Bank does not exist.

  ## Examples

      iex> get_bank!(123)
      %Bank{}

      iex> get_bank!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bank!(id), do: Repo.get!(Bank, id)

  @doc """
  Creates a bank.

  ## Examples

      iex> create_bank(%{field: value})
      {:ok, %Bank{}}

      iex> create_bank(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bank(attrs \\ %{}) do
    %Bank{}
    |> Bank.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bank.

  ## Examples

      iex> update_bank(bank, %{field: new_value})
      {:ok, %Bank{}}

      iex> update_bank(bank, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bank(%Bank{} = bank, attrs) do
    bank
    |> Bank.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bank.

  ## Examples

      iex> delete_bank(bank)
      {:ok, %Bank{}}

      iex> delete_bank(bank)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bank(%Bank{} = bank) do
    Repo.delete(bank)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bank changes.

  ## Examples

      iex> change_bank(bank)
      %Ecto.Changeset{data: %Bank{}}

  """
  def change_bank(%Bank{} = bank, attrs \\ %{}) do
    Bank.changeset(bank, attrs)
  end

  def get_institute(iban) when is_binary(iban) and byte_size(iban) > 10 do
    iban = String.trim(iban)
    countrycode = String.slice(iban, 0, 2)

    bankcode =
      case countrycode do
        "DE" -> String.slice(iban, 4, 8)
        "AT" -> String.slice(iban, 4, 5)
        "CH" -> String.slice(iban, 4, 5)
      end

    get_institute(countrycode, bankcode)
  end

  def can_propose_institute?(iban) when is_binary(iban) do
    iban = String.trim(iban)
    countrycode = String.slice(iban, 0, 2)
    length = String.length(iban)

    case countrycode do
      "DE" -> length >= 12
      "AT" -> length >= 9
      "CH" -> length >= 9
      _ -> false
    end
  end

  def get_institute(countrycode, bankcode) do
    institues =
      Repo.all(
        from(
          b in Bank,
          where: b.bankcode == ^bankcode and b.bic != "" and b.countrycode == ^countrycode,
          distinct: b.bankcode,
          select: b.name
        )
      )

    List.first(institues)
  end

  def check_iban(iban) when is_binary(iban) do
    iban = String.trim(iban)
    countrycode = String.slice(iban, 0, 2)

    valid_length =
      case countrycode do
        "DE" -> 22
        "AT" -> 20
        "CH" -> 21
        _ -> 99
      end

    if String.length(iban) == valid_length do
      # vgl. https://www.hettwer-beratung.de/sepa-spezialwissen/sepa-kontoverbindungsdaten/iban-pr%C3%BCfziffer-berechnung/
      tranformed_iban_for_check = String.slice(iban, 4, 99) <> String.slice(iban, 0, 2) <> "00"

      tranformed_iban_for_check =
        tranformed_iban_for_check
        |> String.upcase()
        |> String.codepoints()
        |> Enum.reduce(
          "",
          fn char, result ->
            <<code::utf8>> = char
            # convert letters to numbers starting with A=10
            value =
              if code in ?A..?Z do
                Integer.to_string(code - 55)
              else
                char
              end

            result <> value
          end
        )

      {tranformed_iban_for_check_as_integer, _} = Integer.parse(tranformed_iban_for_check)
      remainder = Integer.mod(tranformed_iban_for_check_as_integer, 97)
      check_digit = 98 - remainder

      if Integer.to_string(check_digit) == String.slice(iban, 2, 2) do
        {:valid, ""}
      else
        {:invalid, "Die Prüfziffer der IBAN stimmt nicht."}
      end
    else
      if countrycode in ["DE", "CH", "AT"] do
        {:invalid, "IBAN mit #{countrycode} muss genau #{valid_length} Stellen haben."}
      else
        {:no_check, ""}
      end
    end
  end
end
