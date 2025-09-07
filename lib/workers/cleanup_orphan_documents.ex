defmodule Mfin.Workers.CleanupOrphanDocuments do
  use Oban.Worker, queue: :default
  require Logger

  alias Mfin.Blog

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Starting cleanup of orphaned documents")
    Blog.delete_orphan_documents()
    :ok
  end
end
