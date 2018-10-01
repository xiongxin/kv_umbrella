defmodule KV.RouterTest do
  use ExUnit.Case, async: true
  doctest KV.Router
  # test "route requests across nodes" do
  #   assert KV.Router.route("hello", Kernel, :node, []) ==
  #     :"foo@DESKTOP-0GL1EO6"
  #   assert KV.Router.route("world", Kernel, :node, []) ==
  #     :"bar@DESKTOP-0GL1EO6"
  # end

end
