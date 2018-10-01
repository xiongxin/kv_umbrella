{application,kv_server,
             [{applications,[kernel,stdlib,elixir,logger,kv]},
              {description,"kv_server"},
              {modules,['Elixir.KVServer','Elixir.KVServer.Application',
                        'Elixir.KVServer.Command']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.KVServer.Application',[]}}]}.
