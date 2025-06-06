defmodule MfinWeb.ActiveToggleComponent do
  use MfinWeb, :live_component

  def render(assigns) do
    ~H"""
      <label class="inline-flex items-center cursor-pointer">
       <%= if @job.status == 1 do %>
        <input type="checkbox" value="" class="sr-only peer" checked >
       <% else %>
        <input type="checkbox" value="" class="sr-only peer">
       <% end %>
        <div
          phx-click="toggle-activeness"
          phx-value-id={@job.id}
          id={"job-activeness-toggle-#{@job.id}"}
          class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 dark:peer-checked:bg-blue-600"></div>
      </label>
    """
  end

  def active_checked(1), do: "checked"
  def active_checked(_), do: ""


end

