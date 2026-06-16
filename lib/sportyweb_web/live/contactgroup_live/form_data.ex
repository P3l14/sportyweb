defmodule SportywebWeb.ContactGroupLive.ContactGroupForm do
  use Ecto.Schema
  import Ecto.Changeset
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.ContactGroupContact

  @primary_key false
  embedded_schema do
    embeds_one :contact_group, ContactGroup
    embeds_many :contact_group_contacts, ContactGroupContact, on_replace: :delete
  end

  @doc false
  def changeset(contact_group_form, attrs \\ %{}) do
    contact_group_form
    |> cast(attrs, [])
    |> cast_embed(:contact_group, required: true)
    |> cast_embed(
      :contact_group_contacts,
      sort_param: ContactGroup.get_changeset_sort_param(),
      drop_param: ContactGroup.get_changeset_drop_param(),
      with: &changeset_contact_group_contacts/2
    )
    |> validate_unique_contact_group_contacts()
  end

  defp changeset_contact_group_contacts(contact_group_contact, attrs) do
    contact_group_contact
    |> cast(attrs, [:contact_id])
    |> validate_required([:contact_id])
  end

  defp validate_unique_contact_group_contacts(changeset) do
    case get_change(changeset, :contact_group_contacts) do
      nil ->
        changeset

      contact_group_contacts ->
        contact_ids =
          contact_group_contacts
          |> Enum.map(fn contact_group_contacts_changesets ->
            contact_group_contacts_changesets |> get_field(:contact_id)
          end)

        if length(contact_ids) == length(Enum.uniq(contact_ids)) do
          changeset
        else
          changeset
          |> add_error(
            :contact_group_contacts,
            "Der gleiche Kontakt darf nicht zwei Mal der gleichen Kontaktgruppe hinzugefügt werden!"
          )
        end
    end
  end
end
