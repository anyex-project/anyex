defmodule WebServerTest.Router.CategoryRouterTest do
  use WebServer.TestCase

  test "add and update category", state do
    conn =
      conn(:post, "/category/admin", %{
        path: "category-1",
        name: "类别1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map
    assert category.path == "category-1"
    assert category.name == "类别1"

    conn =
      conn(:put, "/category/admin", %{
        id: category.id,
        path: "category-1-updated",
        name: "更新后的类别1"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map
    assert category.path == "category-1-updated"
    assert category.name == "更新后的类别1"

    conn = conn(:delete, "/category/admin/#{category.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map
    assert category.res_status == -1

    conn = conn(:put, "/category/admin/hidden/#{category.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map
    assert category.res_status == 0

    conn = conn(:put, "/category/admin/normal/#{category.id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map
    assert category.res_status == 1
  end

  test "find category list", state do
    1..15
    |> Enum.map(fn i ->
      conn =
        conn(:post, "/category/admin", %{
          path: "category-#{i}",
          name: "类别#{i}"
        })

      conn = conn |> put_json_header |> put_authorization(state) |> call
      assert conn.status == 200
      category = conn |> resp_to_map
      assert category.path == "category-#{i}"
      assert category.name == "类别#{i}"
    end)

    conn = conn(:get, "category/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map

    assert length(list) == 15

    conn = conn(:delete, "/category/admin/#{Enum.at(list, 0).id}")

    conn = conn |> put_authorization(state) |> call
    assert conn.status == 200
    category = conn |> resp_to_map

    assert category.res_status == -1

    conn = conn(:get, "/category/list") |> call
    assert conn.status == 200
    list = conn |> resp_to_map

    assert length(list) == 14

    conn = conn(:get, "/category/admin/list") |> put_authorization(state) |> call
    assert conn.status == 200
    list = conn |> resp_to_map

    assert length(list) == 15
  end
end
