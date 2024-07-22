defmodule Meowmeow.Blog.Post do
  @enforce_keys [:id, :title, :author, :date, :tags, :description, :body]
  defstruct [:id, :title, :author, :date, :tags, :description, :body]

  def build(filename, attrs, body) do
    [y, m, d | rest] =
      filename
      |> Path.rootname()
      |> Path.basename()
      |> String.split("-")

    date = Date.from_iso8601!("#{y}-#{m}-#{d}")

    struct!(
      __MODULE__,
      Map.to_list(attrs) ++
        [
          id: Enum.join(rest, "-"),
          date: date,
          body: body
        ]
    )
  end
end
