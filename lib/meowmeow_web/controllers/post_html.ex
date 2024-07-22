defmodule MeowmeowWeb.PostHTML do
  import MeowmeowWeb.Components

  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use MeowmeowWeb, :html

  embed_templates "post_html/*"
end
