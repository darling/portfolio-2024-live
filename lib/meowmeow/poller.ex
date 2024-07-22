defmodule Meowmeow.ApiPoller do
  use GenServer
  alias Phoenix.PubSub
  alias MeowmeowWeb.Presence

  @poll_interval 20_000
  @presence_topic "music_listeners"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Phoenix.PubSub.subscribe(Meowmeow.PubSub, @presence_topic)
    {:ok, %{timer: nil, last_poll: nil, results: []}}
  end

  def get_results do
    GenServer.call(__MODULE__, :get_results)
  end

  def handle_call(:get_results, _from, state) do
    {res, new_last_poll} = maybe_call_api(state)
    new_state = %{state | results: res, last_poll: new_last_poll}
    {:reply, {:ok, new_state.results}, schedule_poll(new_state)}
  end

  def handle_info(%{event: "presence_diff"}, state) do
    new_state =
      if Presence.list(@presence_topic) |> map_size() > 0 do
        schedule_poll(state)
      else
        cancel_timer(state.timer)
        %{state | timer: nil}
      end

    {:noreply, new_state}
  end

  def handle_info(:poll, state) do
    res = call_api()
    broadcast(res)
    new_state = %{state | results: res, last_poll: System.monotonic_time(:millisecond)}
    {:noreply, schedule_poll(new_state)}
  end

  defp maybe_call_api(state) do
    current_time = System.monotonic_time(:millisecond)

    case state.last_poll do
      nil -> {call_api(), current_time}
      last_poll when current_time - last_poll >= @poll_interval -> {call_api(), current_time}
      _last_poll -> {state.results, state.last_poll}
    end
  end

  defp schedule_poll(state) do
    cancel_timer(state.timer)
    timer = Process.send_after(self(), :poll, @poll_interval)
    %{state | timer: timer}
  end

  defp cancel_timer(nil), do: :ok
  defp cancel_timer(timer), do: Process.cancel_timer(timer)

  defp call_api() do
    case Meowmeow.LastFM.get_recent_tracks() do
      {:ok, songs} ->
        songs

      {:error, msg} ->
        IO.puts("Failed to fetch " <> msg)
        nil
    end
  end

  defp broadcast(payload) do
    PubSub.broadcast(Meowmeow.PubSub, "music_updates", {:music_update, payload})
  end
end
