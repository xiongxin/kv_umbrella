defmodule KV.Registry do
  use GenServer

  ## Client API


  @doc """
  Starts the registry
  """
  def start_link(opts) do
    # __MODULE__ 服务器回调模块名称，当前模块
    # :ok 初始化参数
    # 服务器配置参数， :name, ...
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name) # 使用fetch!在选项中如果没有name参数时会使当前进程crash
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.
  Return `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # 3. Lookup is now done directly in ETS, without accessing the server.
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensure there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, { :create, name }) # async call
  end

  @doc """
  Stops the registry
  """
  def stop(server) do
    GenServer.stop server
  end

  ## Server Callbacks

  # 接收 start_link 的第二个参数
  def init(table) do
    # 2. We have replaced the names map by the ETS table
    # 使用 :name_table 参数时，返回的names就代表table进程
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs  = %{}

    {:ok, {names, refs}} # 返回 {:ok, state}
  end

  # 使用 lookup 方法替代
  # def handle_call({:lookup, name}, _from, {names, refs}) do
  #   {:reply, Map.fetch(names, name), {names, refs}}
  # end

  # 4. The previous handle_call callback for lookup was removed

  def handle_call({:create, name},_from, {names, refs}) do
    # 5. Read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid , {names, refs}} # 已经存在原样返回
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put refs, ref, name
        :ets.insert(names, {name, pid})
        {:reply, pid ,{names, refs}}
    end

    # if Map.has_key?(names, name) do
    #   {:noreply, {names, refs}}
    # else
    #   #{:ok, bucket} = KV.Bucket.start_link([])
    #   {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
    #   ref = Process.monitor(pid) # 监视进程，在进程退出时，会得到message
    #   refs = Map.put refs, ref, name
    #   names= Map.put names,name, pid

    #   {:noreply, {names, refs}}
    # end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop refs, ref
    # names = Map.delete names, name
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end
