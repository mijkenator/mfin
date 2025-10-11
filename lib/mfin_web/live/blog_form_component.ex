defmodule MfinWeb.BlogFormComponent do
  use MfinWeb, :live_component
  
  alias Mfin.Blog
  alias Mfin.Blog.Post

  @impl true
  def update(assigns, socket) do
    {:ok, assign_changeset(assigns, socket)}
  end

  def handle_event(event, params, socket) do

    IO.puts("HE BFC: #{inspect(event)} -> #{inspect(params)}")
    {:noreply, socket}
  end

  defp assign_changeset(assigns, socket) do
    IO.puts("AC PFC: #{inspect(assigns)}")
    
    #current_user = socket.assigns.current_user
    #IO.puts("ULAAN: #{inspect(current_user, limit: :infinity)}")

    post = %Post{
      #author_id: current_user.id,
      author_id: 1,
      documents: []
    }
    ##changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    #changeset = case assigns[:id] do
    #  "0" ->
    #    %{
    #      "id" => 0
    #    }
    #  bin_id ->
    #    Mfin.Egjob.get_job_byid(String.to_integer(bin_id))
    #      |> Map.from_struct
    #      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end) 
    #      |> Enum.into(%{}) 
    #end
    #
    #IO.puts("AC CHANGESET: #{inspect(changeset)}")
    socket
      #|> assign(:title, assigns[:title])
      #|> assign(:id, assigns[:id] )
      #|> assign(:changeset, changeset)
      |> assign(:post, post)
      |> assign(:form, to_form(Blog.change_post(post)))
    socket
  end
  
  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "Unacceptable file type (PDF, JPG, PNG only)"
  defp error_to_string(:too_many_files), do: "Too many files selected"

end
