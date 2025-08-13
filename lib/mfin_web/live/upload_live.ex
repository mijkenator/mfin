defmodule MfinWeb.UploadLive do
  
  use MfinWeb, :live_view
  require Logger

  def mount(_params, _session, socket), do: {:ok, socket}

end
