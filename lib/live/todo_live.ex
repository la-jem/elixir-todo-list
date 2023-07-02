defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  alias ElixirTodoList.Item

  def mount(_params, _session, socket) do
    items = Item.list_items()

    socket = assign(socket, items: items)

    {:ok, socket}
  end

  defp blank?(string), do: "" == string |> to_string() |> String.trim()

  def handle_event("save-item", %{"text" => text}, socket) do
    IO.inspect(blank?(text))

    case blank?(text) do
      false ->
        Item.create_item(%{text: text})

        socket
        |> clear_flash()
        |> put_flash(:info, "Item created successfully")
        |> assign(items: Item.list_items())
        # {:noreply, socket}
        |> (&{:noreply, &1}).()

      true ->
        socket
        |> clear_flash()
        |> put_flash(:error, "Item text should not be empty")
        |> (&{:noreply, &1}).()
    end
  end

  def handle_event("delete-item", data, socket) do
    Item.delete_item(Map.get(data, "id"))

    socket
    |> clear_flash()
    |> put_flash(:info, "Item deleted successfully")
    |> assign(items: Item.list_items())
    |> (&{:noreply, &1}).()
  end

  def render(assigns) do
    ~H"""
    <div id="todo-list">
      <h1>TODO LIST</h1>
      <form id="form" phx-submit="save-item">
        <input
          id="new-item"
          class="new-item"
          type="text"
          name="text"
          placeholder="Add todo list item"
          autocomplete="off"
        />
        <button class="create" phx-disable-with="Saving...">
          Add Todo
        </button>
      </form>

      <div :for={item <- @items} class="item">
        <div class="text">
          <%= item.text %>
        </div>
        <button class="delete" phx-click="delete-item" phx-value-id={item.id}>Delete Todo</button>
      </div>
    </div>
    """
  end
end
