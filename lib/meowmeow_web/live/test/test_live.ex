defmodule MeowmeowWeb.TestLive do
  import MeowmeowWeb.Components
  use MeowmeowWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def terminate(_reason, _socket) do
  end
end
