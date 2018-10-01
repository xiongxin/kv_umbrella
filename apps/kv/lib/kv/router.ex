defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based one the `bucket`
  """
  def route(bucket, mod, fun, args) do
    # Get the first byte of the binary
    first = :binary.first(bucket)

    # Try to find an entry in the table() or raise
    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    # If the entry node in the current node
    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      { KV.RouterTasks, elem(entry, 1) }
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await
    end
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect bucket} in table #{inspect table()}"
  end

  @doc """
  The routing table
  """
  def table do
    # Replace computer-name with you local machine name.
    [
      { ?a..?m, :"foo@DESKTOP-0GL1EO6" },
      { ?n..?z, :"bar@DESKTOP-0GL1EO6" }
    ]
  end

end
