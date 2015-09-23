defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn(entry, todo_list_acc) ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(%TodoList{entries: entries, auto_id: auto_id} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)
    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
        entry.date == date
      end)
    |> Enum.map(fn({_, entry}) ->
        entry
      end)
  end

  def update_entry(%TodoList{entries: entries} = todo_list, entry_id, updater_function) do
    case entries[entry_id] do
      nil -> todo_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_function.(old_entry)
        new_entries = HashDict.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
    %TodoList{todo_list | entries: HashDict.delete(entries, entry_id)}
  end
end

defmodule TodoList.CsvImporter do

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
    split_date = String.split(date, "/")
    parsed_date = Enum.map(split_date, fn(t) -> String.to_integer(t) end)
    [year, month, day] = parsed_date
    {year, month, day}
  end

end







