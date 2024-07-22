defmodule MeowmeowWeb.Components do
  use Phoenix.Component

  slot :inner_block, required: true

  def bold(assigns) do
    ~H"""
    <span class="font-bold text-white"><%= render_slot(@inner_block) %></span>
    """
  end

  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div class="mx-auto max-w-6xl px-4 sm:px-2"><%= render_slot(@inner_block) %></div>
    """
  end

  slot :inner_block, required: true

  def large(assigns) do
    ~H"""
    <span class="text-4xl font-black sm:text-3xl"><%= render_slot(@inner_block) %></span>
    """
  end

  slot :inner_block, required: true
  attr :dest, :string, required: true

  def go(assigns) do
    ~H"""
    <a class="font-bold text-white hover:underline" href={@dest}><%= render_slot(@inner_block) %></a>
    """
  end
end
