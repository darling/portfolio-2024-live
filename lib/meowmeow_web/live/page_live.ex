defmodule MeowmeowWeb.PageLive do
  import MeowmeowWeb.Components
  alias Meowmeow.ApiPoller
  alias Meowmeow.PortfolioData
  alias MeowmeowWeb.Presence
  use MeowmeowWeb, :live_view

  @presence_topic "music_listeners"
  @experiences PortfolioData.experience()
  @portfolio PortfolioData.portfolio()

  def mount(_params, _session, socket) do
    new_socket =
      socket
      |> assign(experiences: @experiences)
      |> assign(portfolio: @portfolio)
      |> assign(results: nil)

    if connected?(socket) do
      {:ok, initial_results} = ApiPoller.get_results()

      Phoenix.PubSub.subscribe(Meowmeow.PubSub, "music_updates")
      Phoenix.PubSub.subscribe(Meowmeow.PubSub, @presence_topic)

      {:ok, _} = Presence.track(self(), @presence_topic, socket.id, %{})

      {:ok, assign(new_socket, results: initial_results)}
    else
      {:ok, new_socket}
    end
  end

  def handle_info({:music_update, results}, socket) do
    {:noreply, assign(socket, results: results)}
  end

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    # Presence will automatically handle cleanup when the process terminates
  end
end
