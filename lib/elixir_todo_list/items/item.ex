defmodule ElixirTodoList.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    # soft-deletion
    # true = deleted
    field :deleted, :boolean, default: false
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text, :deleted])
    |> validate_required([:text, :deleted])
  end
end
