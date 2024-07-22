defmodule Meowmeow.PortfolioData do
  defmodule Experience do
    @moduledoc "Struct for experience data"
    defstruct [:company, :link, :position, :description]

    @type t :: %__MODULE__{
            company: String.t(),
            link: String.t(),
            position: String.t(),
            description: String.t()
          }
  end

  defmodule Project do
    @moduledoc "Struct for portfolio project data"
    defstruct [:title, :description, :type, :link]

    @type t :: %__MODULE__{
            title: String.t(),
            description: String.t(),
            type: :external | :personal,
            link: String.t() | nil
          }
  end

  @spec load() :: %{experience: [Experience.t()], portfolio: [Project.t()]}
  def load do
    yaml_data =
      Application.app_dir(:meowmeow, "priv/static/portfolio_data.yml")
      |> YamlElixir.read_from_file!()

    %{
      experience: parse_experience(yaml_data["experience"]),
      portfolio: parse_portfolio(yaml_data["portfolio"])
    }
  end

  @spec parse_experience([map()]) :: [Experience.t()]
  defp parse_experience(experiences) do
    Enum.map(experiences, fn exp ->
      %Experience{
        company: validate_string(exp["company"]),
        link: validate_string(exp["link"]),
        position: validate_string(exp["position"]),
        description: validate_string(exp["description"])
      }
    end)
  end

  @spec parse_portfolio([map()]) :: [Project.t()]
  defp parse_portfolio(projects) do
    Enum.map(projects, fn proj ->
      %Project{
        title: validate_string(proj["title"]),
        description: validate_string(proj["description"]),
        type: parse_project_type(proj["type"]),
        link: validate_optional_string(proj["link"])
      }
    end)
  end

  @spec parse_project_type(String.t()) :: :external | :personal
  defp parse_project_type("external"), do: :external
  defp parse_project_type("personal"), do: :personal
  defp parse_project_type(invalid), do: raise("Invalid project type: #{invalid}")

  @spec validate_string(term()) :: String.t()
  defp validate_string(value) when is_binary(value), do: value
  defp validate_string(invalid), do: raise("Expected string, got: #{inspect(invalid)}")

  @spec validate_optional_string(term()) :: String.t() | nil
  defp validate_optional_string(nil), do: nil
  defp validate_optional_string(value), do: validate_string(value)

  def experience, do: load().experience
  def portfolio, do: load().portfolio
end
