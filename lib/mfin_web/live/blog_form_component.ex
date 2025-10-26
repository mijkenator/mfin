defmodule MfinWeb.BlogFormComponent do
  use MfinWeb, :live_component
  
  alias Mfin.Blog
  alias Mfin.Blog.Post

  @impl true
  def update(assigns, socket) do
    IO.puts("update BFC:")
    {:ok, assign_changeset(assigns, socket)}
  end

  def handle_event(event, params, socket) do

    IO.puts("HE BFC: #{inspect(event)} -> #{inspect(params)}")
    {:noreply, socket}
  end

  defp assign_changeset(assigns, socket) do
    IO.puts("AC PFC: #{inspect(assigns)}")
    
    #current_user = socket.assigns.current_user
    #IO.puts("BFC current user:: #{inspect(current_user, limit: :infinity)}")

    ##changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    {changeset, post} = case assigns[:id] do
      "0" ->
        {
          %{
            "id" => 0
          },
          post = %Post{
            #author_id: current_user.id,
            author_id: 1,
            title: "new title",
            content: "new contrwnt",
            documents: []
          }
        }
      bin_id ->
        tmp_post = Mfin.Blog.get_post!(String.to_integer(bin_id))
        {
          tmp_post
          |> Map.from_struct
          |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end) 
          |> Enum.into(%{}),
          tmp_post
        }
    end
    IO.puts("AC CHANGESET: #{inspect(changeset)}")
    mform = to_form(Blog.change_post(post))
    IO.puts("BFC FORM: #{inspect(mform, limit: :infinity)}")
    socket
      #|> assign(:title, assigns[:title])
      #|> assign(:id, assigns[:id] )
      |> assign(:changeset, changeset)
      |> assign(:post, post)
      |> assign(:form, mform)
      |> assign(:documents, post.documents)
      |> allow_upload(:document,
       accept: ~w(.pdf .jpg .png),
       max_entries: 5,
       max_file_size: 10_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )
  end
  
  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "Unacceptable file type (PDF, JPG, PNG only)"
  defp error_to_string(:too_many_files), do: "Too many files selected"


  @impl true
  def handle_event(event, params, socket) do
    IO.puts("BFC EVENT:#{inspect(event)}  #{inspect(params)}")
    {:noreply, socket}
  end
  
  defp handle_progress(:document, entry, socket) do
    if entry.done? do
      Logger.debug("Upload finished")

      document =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          upload = %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: path
          }

          {:ok, document} =
            Blog.create_unattached_document(%{"file" => upload}, socket.assigns.current_user)

          document
        end)

      {:noreply,
       socket
       |> update(:documents, &(&1 ++ [document]))}
    else
      {:noreply, socket}
    end
  end

end
