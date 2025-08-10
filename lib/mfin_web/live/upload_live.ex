defmodule MfinWeb.UploadLive do
  
  use MfinWeb, :live_view
  alias Mfin.Egjob
  require Logger

  def mount(_params, _session, socket), do: {:ok, socket}

end
