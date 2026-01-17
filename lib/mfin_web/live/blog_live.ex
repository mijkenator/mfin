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
    }
  end
  
  def handle_params(params, url, socket) do
    IO.puts("PARAMS: #{inspect(url)}  -> #{inspect(params)}")
    IO.puts("BLHP: #{inspect(socket.assigns, limit: :infinity, printable_limit: :infinity)}")

    la = case socket.assigns.live_action do
      nil -> :new
      live_action -> live_action
    end

    blog_action(params["action"], socket, params)
  end

  def blog_action(nil, socket, _) do
    {:noreply,
      socket
      #|> parse_params(params)
      |> assign_blog()
    }
  end
  def blog_action("new", socket, _) do
    current_user = socket.assigns.current_user
    post = %Blog.Post{
      author_id: current_user.id,
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
  end
  def blog_action("delete", socket, params) do
    IO.puts("delete post: #{inspect(params["id"])}")
    Blog.delete_post_byid(params["id"])
    {:noreply,
      socket
      |> push_navigate(to: ~p"/blog")
    }
  end
  def blog_action("delete_selected", socket, params) do
    delete_selected(params, socket)
  end
  def blog_action(action, socket, params) do
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

  defp assign_blog(socket) do
    params = %{}
    socket
    |> assign(:blog, Blog.get_all_posts(params))
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

  
end

