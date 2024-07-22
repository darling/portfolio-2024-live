defmodule Meowmeow.Markdown do
  def convert(_ext, body, _attrs \\ [], _opts \\ []) do
    body
    |> Earmark.as_html!(earmark_options())
    |> highlight_code_blocks()
  end

  defp earmark_options do
    %Earmark.Options{
      smartypants: false,
      pure_links: false,
      escape: false
    }
  end

  defp highlight_code_blocks(html) do
    Regex.replace(~r/<pre><code(?: +class="(\w*)")?>(.+?)<\/code><\/pre>/s, html, fn _,
                                                                                     lang,
                                                                                     code ->
      case Autumn.highlight(code, language: lang, theme: "catppuccin_mocha") do
        {:ok, output} -> output
        {:error, error} -> error
      end
    end)
  end
end

