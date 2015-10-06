defmodule Todo.Database do
  @pool_size 3

  def start_link(db_folder) do
    Todo.PoolSupervisor.start_link(db_folder, @pool_size)
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

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  # def init(db_folder) do
  #   {:ok, start_workers(db_folder)}
  # end

  # def handle_call({:choose_worker, key}, _, workers) do
  #   worker_pid = HashDict.get(workers, :erlang.phash2(key, 3))
  #   {:reply, worker_pid, workers}
  # end

  # defp start_workers(db_folder) do
  #   for index <- 1..3, into: HashDict.new do
  #     {:ok, worker_pid} = Todo.DatabaseWorker.start_link(db_folder, index)
  #     {index, worker_pid}
  #   end
  # end

end