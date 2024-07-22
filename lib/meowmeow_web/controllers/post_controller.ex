defmodule MeowmeowWeb.PostController do
  use MeowmeowWeb, :controller

  alias Meowmeow.Blog

  def all_posts(conn, _params) do
    render(conn, "posts.html", posts: Blog.all_posts())
  end

  def posts(conn, %{"id" => id}) do
    post = Blog.get_post_by_id!(id)
    render(conn, "post.html", post: post)
  end
end
