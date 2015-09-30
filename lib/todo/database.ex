defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  def handle_cast({:store, key, data}, workers) do
    Todo.DatabaseWorker.store(get_worker(workers, key), key, data)
    {:noreply, workers}
  end

  def handle_call({:get, key}, _, workers) do
    data = Todo.DatabaseWorker.get(get_worker(workers, key), key)
    {:reply, data, workers}
  end

  defp start_workers(db_folder) do
    for index <- 0..2, into: HashDict.new do
      {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
      {index, worker_pid}
    end
  end

  defp get_worker(workers, key) do
    HashDict.get(workers, :erlang.phash2(key, 3))
  end
end