defmodule MfinWeb.JobListController do
  use MfinWeb, :controller

  alias Mfin.Egjob

  def list(conn, _params) do
    jobs = Egjob.get_all_jobs()
    render(conn, :list, jobs: jobs)
  end

end

