defmodule ElixirTodoListWeb.TodoLive do
  use ElixirTodoListWeb, :live_view

  alias ElixirTodoList.Items
  # alias ElixirTodoList.Accounts

  def mount(_params, session, socket) do
    items = Items.list_items(socket.assigns.current_user.id)

    # Done by the on_mount callback (:ensure_authenticated)
    # user = Accounts.get_user_by_session_token(session["user_token"])

    socket =
      assign(socket,
        items: items,
        editing: nil,
        session_id: session["live_socket_id"]
        # current_user: user
      )

    {:ok, socket}
  end

  defp blank?(string), do: "" == string |> to_string() |> String.trim()

  def handle_event("save-item", %{"text" => text}, socket) do
    current_user = socket.assigns.current_user.id
    IO.inspect(blank?(text))

    # Refactor to its own handler
    # Check if text is blank
    # Trigger appropriate action
    case blank?(text) do
      false ->
        Items.create_item(%{text: text, user_id: current_user})

        socket
        |> clear_flash()
        |> put_flash(:info, "Item created successfully")
        |> assign(items: Items.list_items(current_user))
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
    current_user = socket.assigns.current_user.id
    Items.delete_item(Map.get(data, "id"))

    socket
    |> clear_flash()
    |> put_flash(:info, "Item deleted successfully")
    |> assign(items: Items.list_items(current_user))
    |> (&{:noreply, &1}).()
  end

  def handle_event("update-item", %{"id" => item_id, "text" => text}, socket) do
    current_user = socket.assigns.current_user.id

    case blank?(text) do
      false ->
        current_item = Items.get_item!(item_id)
        Items.update_item(current_item, %{text: text})

        socket
        |> clear_flash()
        |> put_flash(:info, "Item updated successfully")
        |> assign(items: Items.list_items(current_user), editing: nil)
        |> (&{:noreply, &1}).()

      true ->
        socket
        |> clear_flash()
        |> put_flash(:error, "Item text should not be empty")
        |> assign(items: Items.list_items(current_user), editing: nil)
        |> (&{:noreply, &1}).()
    end
  end

  def handle_event("update-item", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
  end
end
