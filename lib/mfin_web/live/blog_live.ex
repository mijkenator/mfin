defmodule MfinWeb.BlogLive do
  
  use MfinWeb, :live_view
  alias Mfin.Blog
  alias Mfin.Accounts
  require Logger

  def mount(_params, session, socket) do 
    IO.puts("BLmount: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    #sp = Map.get(socket.assigns, :selected_posts, [])
    {:ok, 
      socket
      |> assign_new(:current_user, fn ->
          if user_token = session["user_token"] do
            Accounts.get_user_by_session_token(user_token)
          else
            nil
           end
      end)
       #|> assign(:selected_posts, sp)
      # |> allow_upload(:document,
      #   accept: ~w(.pdf .jpg .png),
      #   max_entries: 5,
      #   max_file_size: 10_000_000,
      #   auto_upload: true,
      #   progress: &handle_progress/3
      # )
    }
  end
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
    IO.puts("BLHP: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")

    la = case socket.assigns.live_action do
      nil -> :new
      live_action -> live_action
    end

    case params["action"] do
      nil ->
        {:noreply,
          socket
          #|> parse_params(params)
          |> assign_blog()
        }
      "new" ->
        post = %Blog.Post{
          #author_id: current_user.id,
          author_id: 1,
          documents: []
        }

        {:noreply,
          socket
          |> assign(:live_action, "new")
          |> assign(:page_title, "New Blog Post")
          |> assign(:post, post)
          |> assign(:documents, [])
          |> assign(:post_id, "0")
          |> assign(:form, to_form(Blog.change_post(post)))
        }
      "delete" ->
        IO.puts("delete post: #{inspect(params["id"])}")
        Blog.delete_post_byid(params["id"])
        {:noreply,
          socket
          |> push_navigate(to: ~p"/blog")
        }
      "delete_selected" ->
        delete_selected(params, socket)
      action ->  
        post = Blog.get_post!( params["id"])
        IO.puts("DOCUMENTS: #{inspect(post.documents)}")
        socket = socket
        |> assign(:live_action, action)
        |> assign(:post_id, params["id"])
        |> assign(:post, post)
        |> assign(:documents, post.documents)
        |> assign(:changeset, Mfin.Egjob.get_job_byid(String.to_integer(params["id"])))
        {:noreply, assign_blog(socket)}
    end
  end

  defp assign_blog(socket) do
    params = %{}
    socket
    |> assign(:blog, Blog.get_all_posts(params))
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
    IO.puts("BLHE: #{inspect(socket.assigns, limit: :infinity)}")
    IO.puts("BLHE LiveAction: #{inspect(socket.assigns.live_action, limit: :infinity)}")
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

  def handle_event("toggle-activeness", assigns, socket) do
    IO.puts("POST TOGGLE: #{inspect(assigns)}")
    Blog.toggle_post_status(String.to_integer(assigns["id"]))
    {:noreply, assign_blog(socket)}
  end
  
  def handle_event("select_checkbox", %{"id" => id, "value" => _value}, socket) do
    sassigns = Map.get(socket.assigns, :selected_posts, [])
    {:noreply, assign(socket, :selected_posts, 
      Enum.uniq([id | sassigns]))}
  end
  def handle_event("select_checkbox", %{"id" => id}, socket) do
    sassigns = List.delete(
      Map.get(socket.assigns, :selected_posts, []),
      id)

    {:noreply, assign(socket, :selected_posts, sassigns)}
  end

  defp delete_selected(params, socket) do
    sp = for pid <- Map.get(socket.assigns, :selected_posts, []), do: String.to_integer(pid)
    IO.puts("delete selected: #{inspect(sp)}")
    Blog.delete_posts(sp)  
    {:noreply,
      socket
      |> push_navigate(to: ~p"/blog")
    }
  end

  defp save_post(socket, "edit", post_params) do
    case Blog.update_post(
           socket.assigns.post,
           post_params,
           socket.assigns.documents
         ) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_navigate(to: ~p"/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
  
  defp save_post(socket, "new", post_params) do
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
         |> push_navigate(to: ~p"/blog")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

