defmodule Todo.CsvImporter do
  def create_todos(path) do
    filter_lines(path)
    |> split_lines
    |> Enum.map(fn([date|title]) ->
        parsed_title = to_string(title)
        parsed_date = parse_date(date)
        %{date: parsed_date, title: parsed_title}
      end
    )
  end

  defp filter_lines(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp split_lines(lines) do
    Stream.map(lines, &String.split(&1, ", "))
  end

  defp parse_date(date) do
    String.split(date, "/")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end
end