defmodule Mfin.Workers.PhotolibJobs do
  use Oban.Worker, queue: :photolib
  require Logger

  alias Mfin.Blog

  @impl Oban.Worker
  def perform(job) do
    Mfin.Photolib.process_import(job.args["path"], job.args["picture"])
  end
  
  def set_job(path, picture) do
    jb = %{ 
      path: path,
      picture: picture
    }
    
    Mfin.Workers.PhotolibJobs.new(jb)
    |> Oban.insert()
  end

end
