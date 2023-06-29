# Refactor: Separate the crud operations from the model itself
# Since soft-deletion is implemented, filter out deleted records from all operations
# https://hexdocs.pm/ecto/Ecto.Repo.html#c:prepare_query/3-examples

defmodule ElixirTodoList.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias ElixirTodoList.Repo

  # https://stackoverflow.com/questions/39854281/how-to-access-struct-inside-module-where-struct-defined-elixir/47501059
  alias __MODULE__

  schema "items" do
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

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{text: "Learn LiveView"})
      {:ok, %Item{}}

      iex> create_item(%{text: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> changeset(attrs)
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
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    query =
      from i in Item,
        where: i.deleted == false

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
