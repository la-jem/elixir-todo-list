defmodule ElixirTodoList.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    # soft-deletion
    # true = deleted
    field :deleted, :boolean, default: false
    field :text, :string

    belongs_to :user, ElixirTodoList.Accounts.User
    # belongs_to list
    # belongs_to board

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:text, :deleted, :user_id])
    |> validate_required([:text, :deleted, :user_id])
  end
end
