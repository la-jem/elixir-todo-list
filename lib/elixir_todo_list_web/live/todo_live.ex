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
end
