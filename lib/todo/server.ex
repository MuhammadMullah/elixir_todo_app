defmodule Todo.Server do
  use GenServer

  def start(entries \\ []) do
    GenServer.start(Todo.Server, entries)
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def init(entries) do
    {:ok, Todo.List.new(entries)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_function}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry_id, updater_function)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end
end