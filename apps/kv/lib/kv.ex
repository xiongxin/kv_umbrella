defmodule KV do
  use Application

  def start(_type, _args) do
    # 应用启动时开启 Kv.Supervisort进程
    KV.Supervisor.start_link(name: KV.Supervisor)
  end

end
