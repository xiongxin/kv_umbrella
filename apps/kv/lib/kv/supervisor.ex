defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      # 开启要给动态监视器
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},

      # 指定开启进程名称为 :KV.Registry 的 KV.Registry进程
      # 相当于传递 opts =  [{:name, KV.Registry}] 到 KV.Registry.start_link(opts)
      {KV.Registry, name: KV.Registry},

      {Task.Supervisor, name: KV.RouterTasks},
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

end
