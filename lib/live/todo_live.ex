defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  alias ElixirTodoList.Item

  def mount(_params, _session, socket) do
    items = Item.list_items()

    socket = assign(socket, items: items, editing: nil)

    {:ok, socket}
  end

  defp blank?(string), do: "" == string |> to_string() |> String.trim()

  def handle_event("save-item", %{"text" => text}, socket) do
    IO.inspect(blank?(text))

    # Refactor to its own handler
    # Check if text is blank
    # Trigger appropriate action
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

  def handle_event("update-item", %{"id" => item_id, "text" => text}, socket) do
    case blank?(text) do
      false ->
        current_item = Item.get_item!(item_id)
        Item.update_item(current_item, %{text: text})

        socket
        |> clear_flash()
        |> put_flash(:info, "Item updated successfully")
        |> assign(items: Item.list_items(), editing: nil)
        |> (&{:noreply, &1}).()

      true ->
        socket
        |> clear_flash()
        |> put_flash(:error, "Item text should not be empty")
        |> assign(items: Item.list_items(), editing: nil)
        |> (&{:noreply, &1}).()
    end
  end

  def handle_event("update-item", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
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
        <%= if item.id == @editing do %>
          <form phx-submit="update-item" id="form-update">
            <input id="update-item" class="new-item" type="text" name="text" value={item.text} />
            <input type="hidden" name="id" value={item.id} />
            <button class="update" phx-disable-with="Saving...">
              Update Todo
            </button>
          </form>
        <% else %>
          <div class="text">
            <%= item.text %>
          </div>
          <button class="update" phx-click="update-item" phx-value-id={item.id}>Edit Todo</button>
          <button class="delete" phx-click="delete-item" phx-value-id={item.id}>Delete Todo</button>
        <% end %>
      </div>
    </div>
    """
  end
end
