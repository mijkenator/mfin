defmodule MfinWeb.FilterComponent do
  use MfinWeb, :live_component

  alias MfinWeb.Forms.FilterForm

  def render(assigns) do
    ~H"""
    <div id="table-filter" class="w-full pb-5">
      <.form :let={f} for={@changeset} as={:filter} phx-submit="search" phx-target={@myself} >
        <div class="flex flex-row space-x-4 ...">
          <div class="w-1/3">
            <.input field={f[:id]} type="number" label="Id"  />
          </div>
          <div class="w-1/3">
            <.input field={f[:name]} type="text" label="Name" />
          </div>
          <div class="btn-submit flex w-1/3 items-end">
              <button type="submit" class="text-white bg-blue-700 hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300 font-medium rounded-full text-sm px-5 py-2.5 text-center me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"> 
                Search
              </button>
              <button phx-click="filter-reset-click" class="text-white bg-blue-700 hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300 font-medium rounded-full text-sm px-5 py-2.5 text-center me-2 mb-2 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"> 
                Reset
              </button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  def handle_event("search", %{"filter" => filter}, socket) do
    case FilterForm.parse(filter) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_changeset(%{filter: filter}, socket) do
    assign(socket, :changeset, FilterForm.change_values(filter))
  end
end
