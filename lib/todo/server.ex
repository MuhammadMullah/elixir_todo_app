defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    IO.puts "Starting #{name} Todo Server..."
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update_entry, entry_id, updater_function}, {name, todo_list}) do
    new_state = Todo.List.update_entry(todo_list, entry_id, updater_function)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_state = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
end