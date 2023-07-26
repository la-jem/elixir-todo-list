# Refactor: Separate the crud operations from the model itself
# Since soft-deletion is implemented, filter out deleted records from all operations
# https://hexdocs.pm/ecto/Ecto.Repo.html#c:prepare_query/3-examples

defmodule ElixirTodoList.Items do
  alias ElixirTodoList.Repo

  alias ElixirTodoList.Items.Item

  import Ecto.Query, only: [from: 2]
  # import ElixirTodoList.Accounts, only: [get_user!: 1]

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    # Fetch the user from the database based on the user_id in attrs
    # user = get_user!(attrs[:user_id])
    # attrs_with_user_id = Map.put(attrs, :user_id, user.id)

    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Returns the list of items given a user id.

  ## Examples

      iex> list_items(user_id)
      [%Item{}, ...]

  """
  def list_items(user_id) do
    query =
      from i in Item,
        where: i.deleted == false and i.user_id == ^user_id,
        # Update to select the ranking when added
        order_by: [desc: i.inserted_at]

    Repo.all(query)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs \\ %{}) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Soft deletes an item

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(id) do
    get_item!(id)
    |> Item.changeset(%{deleted: true})
    |> Repo.update()
  end
end
