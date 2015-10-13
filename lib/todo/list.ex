defmodule Todo.List do
  # Internal structure is changed here. Instead of keeping plain list of entries,
  # we split it per each day. This allows us to quickly fetch entries for the
  # given day, but also to reduce the amount of data that must be store to the
  # database on each change.
  defstruct days: HashDict.new, size: 0

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    %Todo.List{todo_list |
      days: HashDict.update(todo_list.days, entry.date, [entry], &[entry | &1]),
      size: todo_list.size + 1
    }
  end

  def entries(%Todo.List{days: days}, date) do
    days[date]
  end

  # We need this to restore entries for the given date from the database.
  def set_entries(todo_list, date, entries) do
    %Todo.List{todo_list | days: HashDict.put(todo_list.days, date, entries)}
  end
end


## OLD LIST MODULE #####
# defmodule Todo.List do
#   defstruct auto_id: 1, entries: HashDict.new

#   def new(entries \\ []) do
#     Enum.reduce(
#       entries,
#       %Todo.List{},
#       fn(entry, todo_list_acc) ->
#         add_entry(todo_list_acc, entry)
#       end
#     )
#   end

#   def add_entry(%Todo.List{entries: entries, auto_id: auto_id} = todo_list, entry) do
#     entry = Map.put(entry, :id, auto_id)
#     new_entries = HashDict.put(entries, auto_id, entry)
#     %Todo.List{todo_list | entries: new_entries, auto_id: auto_id + 1}
#   end

#   def entries(%Todo.List{entries: entries}, date) do
#     entries
#     |> Stream.filter(fn({_, entry}) ->
#         entry.date == date
#       end)
#     |> Enum.map(fn({_, entry}) ->
#         entry
#       end)
#   end

#   def update_entry(%Todo.List{entries: entries} = todo_list, entry_id, updater_function) do
#     case entries[entry_id] do
#       nil -> todo_list

#       old_entry ->
#         old_entry_id = old_entry.id
#         new_entry = %{id: ^old_entry_id} = updater_function.(old_entry)
#         new_entries = HashDict.put(entries, new_entry.id, new_entry)
#         %Todo.List{todo_list | entries: new_entries}
#     end
#   end

#   def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
#     %Todo.List{todo_list | entries: HashDict.delete(entries, entry_id)}
#   end
# end