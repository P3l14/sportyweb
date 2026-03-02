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
      drop_param: ContactGroup.get_changeset_drop_param()
    )
  end
end
