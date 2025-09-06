defmodule MfinWeb.UploadLive do
  
  use MfinWeb, :live_view
  require Logger

  alias Mfin.Blog
  alias Mfin.Blog.Post
  alias Mfin.Accounts

  @impl true
  def mount(_params, session, socket) do
    IO.puts("ULmount: #{inspect(socket, limit: :infinity, printable_limit: :infinity)}")
    IO.inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)
    {:ok,
      socket
      |> assign_new(:current_user, fn ->
          if user_token = session["user_token"] do
            Accounts.get_user_by_session_token(user_token)
          else
            nil
           end
     end)
     |> allow_upload(:document,
       accept: ~w(.pdf .jpg .png),
       max_entries: 5,
       max_file_size: 10_000_000,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("ULHP: #{inspect(socket.assigns, limit: :infinity)}")
    la = case socket.assigns.live_action do
      nil -> :new
      live_action -> live_action
    end

    {:noreply, apply_action(socket, la, params)}
  end

  defp apply_action(socket, :new, _params) do
    current_user = socket.assigns.current_user
    IO.puts("ULAAN: #{inspect(current_user, limit: :infinity)}")

    post = %Post{
      #author_id: current_user.id,
      author_id: 1,
      documents: []
    }

    socket
    |> assign(:page_title, "New Blog Post")
    |> assign(:post, post)
    |> assign(:documents, [])
    |> assign(:live_action, :new)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)

    socket
    |> assign(:page_title, "Edit Blog Post")
    |> assign(:post, post)
    |> assign(:documents, post.documents)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      Blog.change_post(socket.assigns.post, post_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    IO.puts("ULHE: #{inspect(socket.assigns, limit: :infinity)}")
    la = case socket.assigns.live_action do
      nil -> :new
      live_action -> live_action
    end
    save_post(socket, la, post_params)
  end

  @impl true
  def handle_event("delete-document", %{"id" => document_id}, socket) do
    post = socket.assigns.post
    documents = socket.assigns.documents

    document_to_delete = Blog.get_document!(document_id)

    # Remove from documents list
    documents = Enum.reject(documents, &(&1.id == document_to_delete.id))

    {:noreply, assign(socket, :documents, documents)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :document, ref)}
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
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_navigate(to: ~p"/blog/posts/#{post}")}

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
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_navigate(to: ~p"/blog/posts/#{post}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp error_to_string(:too_large), do: "File is too large (max 10MB)"
  defp error_to_string(:not_accepted), do: "Unacceptable file type (PDF, JPG, PNG only)"
  defp error_to_string(:too_many_files), do: "Too many files selected"

end
