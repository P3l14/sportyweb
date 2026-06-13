defmodule Sportyweb.Personal.ContactIdentificationNumber do
  @moduledoc """
  Provides functions to generate contact identifications number and validate the number.
  The contact identifications number for a contact of a club identifies the contact within the club by this number.
  The actual highest number for a club is saved in the database.
  The check digit is calculated with the [damm alogrithm](https://en.wikipedia.org/wiki/Damm_algorithm)

  """
  use Ecto.Schema
  import Ecto.Query, warn: false

  alias Sportyweb.Repo
  alias Sportyweb.Personal.ContactIdentificationNumber
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_identification_numbers" do
    belongs_to :club, Club
    field :identification_number, :integer, default: 1_000_000

    timestamps(type: :utc_datetime)
  end

  defp get_next(club_id) do
    initial_value = %ContactIdentificationNumber{
      club_id: club_id
    }

    conflict_query =
      from(contact_identification_number in ContactIdentificationNumber,
        update: [inc: [identification_number: 1]]
      )

    contact_identification_number =
      Repo.insert!(
        initial_value,
        on_conflict: conflict_query,
        conflict_target: :club_id,
        returning: [:identification_number]
      )

    contact_identification_number.identification_number
  end

  def generate_new(nil) do
    nil
  end

  @doc """
  Generates a new contact identification number for a contact in a club.
  To generate number identifies a contact in a club.
  The contact identification number consists of a number starting with 1_000_000 with check digit appended.
  The check digit is calculated with the hamm algorithm.


  """
  def generate_new(club_id) do
    club_id |> get_next() |> append_check_digit()
  end

  defp append_check_digit(identification_number_without_check_digit)
       when is_number(identification_number_without_check_digit) do
    check_digit = identification_number_without_check_digit |> get_check_digit()
    identification_number_without_check_digit * 10 + check_digit
  end

  @doc """
  Validates the identification number by calculating the check digit.

  """
  def valid?(identification_number) do
    identification_number |> get_check_digit() == 0
  end

  # Calculates the check digit.
  # The functions is also used for the validation of complete identification number. In this case the calculate check digit is 0 for valid identification number.
  defp get_check_digit(identification_number) do
    identification_number
    |> Integer.digits()
    |> Enum.reduce(0, fn number, acc -> damm_matrix() |> elem(acc) |> elem(number) end)
  end

  defp damm_matrix() do
    {
      {0, 3, 1, 7, 5, 9, 8, 6, 4, 2},
      {7, 0, 9, 2, 1, 5, 4, 8, 6, 3},
      {4, 2, 0, 6, 8, 7, 1, 3, 5, 9},
      {1, 7, 5, 0, 9, 8, 3, 4, 2, 6},
      {6, 1, 2, 3, 0, 4, 5, 9, 7, 8},
      {3, 6, 7, 4, 2, 0, 9, 5, 8, 1},
      {5, 8, 6, 9, 7, 2, 0, 1, 3, 4},
      {8, 9, 4, 5, 3, 6, 2, 0, 1, 7},
      {9, 4, 3, 8, 6, 1, 7, 2, 0, 5},
      {2, 5, 8, 1, 4, 3, 6, 7, 9, 0}
    }
  end
end
