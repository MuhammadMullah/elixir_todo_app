defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)
  end

  def init(db_folder) do
    {:ok, start_workers(db_folder)}
  end

  def handle_call({:choose_worker, key}, _, workers) do
    worker_pid = HashDict.get(workers, :erlang.phash2(key, 3))
    {:reply, worker_pid, workers}
  end

  defp start_workers(db_folder) do
    for index <- 0..2, into: HashDict.new do
      {:ok, worker_pid} = Todo.DatabaseWorker.start(db_folder)
      {index, worker_pid}
    end
  end

  defp choose_worker(key) do
    GenServer.call(:database_server, {:choose_worker, key})
  end
end