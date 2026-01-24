defmodule MfinWeb.BlogHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use MfinWeb, :html

  embed_templates "blog_html/*"
end
