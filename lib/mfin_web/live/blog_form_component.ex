defmodule MfinWeb.BlogFormComponent do
  use MfinWeb, :live_component
  
  alias Mfin.Blog
  alias Mfin.Blog.Post
  require Logger

  @impl true
  def update(assigns, socket) do
    IO.puts("update BFC:")
    {:ok, assign_changeset(assigns, socket)}
  end


  defp assign_changeset(assigns, socket) do
    IO.puts("AC PFC: #{inspect(assigns)}")
    current_user = assigns.current_user
    IO.puts("BFC current user:: #{inspect(current_user, limit: :infinity)}")

    ##changeset = Mfin.Egjob.changeset(%Mfin.Egjob{}, assigns)
    {changeset, post} = case assigns[:id] do
      "0" ->
        {
          %{
            "id" => 0
          },
          %Post{
            author_id: current_user.id,
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
      |> assign(:current_user, current_user)
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
  def handle_event("validate", %{"post" => post_params}, socket) do
    IO.puts("BFC VALIDATE EVENT: #{inspect(post_params)}")
    changeset =
      Blog.change_post(socket.assigns.post, post_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end
  
  @impl true
  def handle_event("delete-document", %{"id" => document_id}, socket) do
    _post = socket.assigns.post
    documents = socket.assigns.documents

    document_to_delete = Blog.get_document!(document_id)

    # Remove from documents list
    documents = Enum.reject(documents, &(&1.id == document_to_delete.id))

    {:noreply, assign(socket, :documents, documents)}
  end
  
  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    IO.puts("Component BLHE: #{inspect(socket.assigns, limit: :infinity)}")
    IO.puts("Component BLHE PostID: #{inspect(socket.assigns.post.id, limit: :infinity)}")
    la = case socket.assigns.post.id do
      nil -> :new
      _live_action -> :edit
    end
    save_post(socket, la, post_params)
  end
  
  def handle_event(event, params, socket) do
    IO.puts("HE BFC DEFAULT: #{inspect(event)} -> #{inspect(params)}")
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
  
  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(
           socket.assigns.post,
           post_params,
           socket.assigns.documents
         ) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_navigate(to: ~p"/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  
  defp save_post(socket, :new, post_params) do
    current_user = socket.assigns.current_user

    case Blog.create_post(
           post_params,
           socket.assigns.documents,
           current_user
         ) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_navigate(to: ~p"/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

end
