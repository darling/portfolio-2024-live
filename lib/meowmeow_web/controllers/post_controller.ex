defmodule MeowmeowWeb.PostController do
  use MeowmeowWeb, :controller

  alias Meowmeow.Blog

  def all_posts(conn, _params) do
    conn = assign(conn, :page_title, "all posts")
    render(conn, "posts.html", posts: Blog.all_posts())
  end

  def posts(conn, %{"id" => id}) do
    post = Blog.get_post_by_id!(id)
    conn = assign(conn, :page_title, String.downcase(post.title))
    render(conn, "post.html", post: post)
  end
end
