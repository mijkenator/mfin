defmodule MfinWeb.BlogLive do
  
  use MfinWeb, :live_view
  alias Mfin.Blog
  alias Mfin.Accounts
  require Logger

  def mount(_params, session, socket) do 
    IO.puts("BLmount: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")
    {:ok, 
      socket
      |> assign_new(:current_user, fn ->
          if user_token = session["user_token"] do
            Accounts.get_user_by_session_token(user_token)
          else
            nil
           end
     end)
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
  
end

