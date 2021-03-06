defmodule PhxcrdWeb.RoomChannel do
  use PhxcrdWeb, :channel
  # use Phoenix.Channel
  alias PhxcrdWeb.Presence

  intercept ["presence_diff"]

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def join("room:lobby", payload, socket) do
    if authorized?(payload) == true do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second)),
        username: socket.assigns[:username],
        authority_name: socket.assigns[:authority_name]
      })

    if socket.assigns[:perms] |> Enum.member?("superuser") do
      push(socket, "presence_state", Presence.list(socket))
    end

    {:noreply, socket}
  end

  def handle_out("presence_diff", msg, socket) do
    if socket.assigns[:perms] |> Enum.member?("superuser"), do: push(socket, "presence_diff", msg)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
