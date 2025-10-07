defmodule PlanningPoker.Router.PlayerTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  @opts PlanningPoker.Router.init([])

  test "creates player and get player" do
    conn = conn(:post, "/api/players", Jason.encode!(%{name: "Alice"}))
    conn = PlanningPoker.Router.call(conn, @opts)

    assert conn.status == 201

    response = Jason.decode!(conn.resp_body)
    assert %{"name" => "Alice", "uuid" => uuid} = response
    assert String.length(uuid) > 0

    conn = conn(:get, "/api/players/#{uuid}")
    conn = PlanningPoker.Router.call(conn, @opts)
    assert conn.status == 200
    response = Jason.decode!(conn.resp_body)
    assert %{"name" => "Alice", "uuid" => ^uuid} = response
  end

  test "get non-existing player" do
    conn = conn(:get, "/api/players/non_existing_uuid")
    conn = PlanningPoker.Router.call(conn, @opts)
    assert conn.status == 404
    response = Jason.decode!(conn.resp_body)
    assert %{"error" => "Player not found"} = response
  end

  test "create player with invalid data" do
    conn = conn(:post, "/api/players", Jason.encode!(%{invalid: "data"}))
    conn = PlanningPoker.Router.call(conn, @opts)
    assert conn.status == 422
    response = Jason.decode!(conn.resp_body)
    assert %{"error" => "Invalid data"} = response
  end
end
