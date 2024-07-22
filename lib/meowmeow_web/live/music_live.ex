defmodule MeowmeowWeb.MusicResultsLive do
  import MeowmeowWeb.Components
  use MeowmeowWeb, :live_component

  defp is_playing(_songs = [first_song | _]) do
    first_song.now_playing
  end

  defp is_playing(_songs) do
    false
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="animate-fade-in md:flex-grow flex flex-col md:justify-end gap-2">
      <%= if @songs != [] do %>
        <h2>
          <%= if is_playing(@songs) do %>
            <.large>now playing</.large>
          <% else %>
            <.large>recent tracks</.large>
          <% end %>
        </h2>
        <ul class="flex flex-col gap-4" id={"#{@id}-songs-list"}>
          <li
            :for={song <- @songs}
            data-id={song.id}
            id={song.id}
            class="flex space-x-2 transition-all duration-300 ease-in-out"
          >
            <div class="flex-grow w-full">
              <h4 class="flex flex-row items-center">
                <div
                  :if={song.now_playing}
                  class="w-2 h-2 aspect-square rounded-full bg-blush -ml-4 mr-2 animate-ping absolute"
                />
                <span class="text-lg font-bold text-white">
                  <%= song.name %>
                </span>
              </h4>
              <p class="text-sm"><%= song.artist %></p>
            </div>
            <a href={song.url} target="_blank" rel="noopener noreferrer" class="hover:underline"></a>
          </li>
        </ul>
      <% end %>
    </div>
    """
  end

  def update(%{id: id, results: results}, socket) do
    socket =
      socket
      |> assign(:id, id)
      |> assign(:songs, results || [])

    {:ok, socket}
  end
end
