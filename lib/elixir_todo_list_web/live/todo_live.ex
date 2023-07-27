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

  # Move to changeset
  # Consider using validate_length/3 https://hexdocs.pm/ecto/Ecto.Changeset.html#validate_length/3
  defp is_blank?(string), do: "" == string |> to_string() |> String.trim()

  defp validate_blank_text(socket, text, success_fn, success_msg, failure_msg) do
    case is_blank?(text) do
      false ->
        success_fn.(socket)

        socket
        |> clear_flash()
        |> put_flash(:info, success_msg)
        |> assign(items: Items.list_items(socket.assigns.current_user.id), editing: nil)
        # {:noreply, socket}
        |> (&{:noreply, &1}).()

      true ->
        socket
        |> clear_flash()
        |> put_flash(:error, failure_msg)
        |> (&{:noreply, &1}).()
    end
  end

  def handle_event("save-item", %{"text" => text}, socket) do
    validate_blank_text(
      socket,
      text,
      &Items.create_item(%{text: text, user_id: &1.assigns.current_user.id}),
      "Item created successfully",
      "Item should not be empty"
    )
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
    validate_blank_text(
      socket,
      text,
      &Items.update_item(Items.get_item!(item_id), %{
        text: text,
        user_id: &1.assigns.current_user.id
      }),
      "Item updated successfully",
      "Item text should not be empty"
    )
  end

  def handle_event("update-item", data, socket) do
    {:noreply, assign(socket, editing: String.to_integer(data["id"]))}
  end
end
