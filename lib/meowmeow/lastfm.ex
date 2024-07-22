defmodule Meowmeow.LastFM do
  use HTTPoison.Base

  @base_url "http://ws.audioscrobbler.com/2.0/"

  def get_recent_tracks(limit \\ 3) do
    api_key = Application.get_env(:meowmeow, :lastfm)[:api_key]
    username = Application.get_env(:meowmeow, :lastfm)[:username]

    params = [
      method: "user.getrecenttracks",
      user: username,
      api_key: api_key,
      format: "json",
      # Fetch 50 tracks
      limit: 50
    ]

    case get(@base_url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_and_process_response(body, limit)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Request failed with status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  defp parse_and_process_response(body, limit) do
    case Jason.decode(body) do
      {:ok, %{"recenttracks" => %{"track" => tracks}}} ->
        processed_tracks =
          tracks
          |> Enum.map(&clean_track_info/1)
          |> Enum.uniq_by(fn track -> {track.artist, track.album} end)
          |> Enum.take(limit)

        {:ok, processed_tracks}

      {:ok, _} ->
        {:error, "No recent tracks found"}

      {:error, _} ->
        {:error, "Failed to parse response"}
    end
  end

  defp clean_track_info(track) do
    now_playing = track["@attr"] && track["@attr"]["nowplaying"] == "true"
    images = track["image"]
    image_url = get_image_url(images)

    %{
      id: track["url"],
      name: track["name"],
      artist: track["artist"]["#text"],
      album: track["album"]["#text"],
      url: track["url"],
      now_playing: now_playing,
      image_url: image_url,
      date: parse_date(track["date"])
    }
  end

  defp get_image_url(images) when is_list(images) do
    images
    |> Enum.find(&(&1["size"] == "large"))
    |> case do
      nil -> nil
      image -> image["#text"]
    end
  end

  defp get_image_url(_), do: nil

  defp parse_date(%{"uts" => uts}) when is_binary(uts) do
    case Integer.parse(uts) do
      {timestamp, _} -> DateTime.from_unix!(timestamp)
      _ -> nil
    end
  end

  defp parse_date(_), do: nil
end
