defmodule WebServerTest.Router.CommentRouterTest do
  use WebServer.Test.Case

  test "add and update comment", state do
    conn = conn(:post, "/category/admin", %{qname: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data

    conn =
      conn(:post, "/article/admin", %{
        qtext: "i-am-first-article",
        title: "我是第一篇文章",
        category: c1
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    article = r.data

    conn =
      conn(:post, "/comment/add", %{
        article_id: article.id,
        author_email: "me@bluerain.io",
        author_nickname: "绅士喵",
        content: "我是评论内容～"
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data
    assert c1.owner == false

    conn =
      conn(:post, "/comment/admin/add", %{
        article_id: article.id,
        author_email: "me@bluerain.io",
        author_nickname: "我才是绅士喵",
        content: "你个冒牌货！没有 owner 标记1",
        parent_id: c1.id
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    assert r.data.owner == true
  end

  test "find comment list", state do
    conn = conn(:post, "/category/admin", %{qname: "c1", name: "类别1"})
    conn = conn |> put_json_header |> put_authorization(state) |> call

    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    c1 = r.data

    conn =
      conn(:post, "/article/admin", %{
        qtext: "i-am-first-article",
        title: "我是第一篇文章",
        category: c1
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    article = r.data

    [_c1, _c2, c3] =
      1..3
      |> Enum.map(fn i ->
        conn =
          conn(:post, "/comment/add", %{
            article_id: article.id,
            author_email: "bot#{i}@bluerain.io",
            author_nickname: "绅士喵 #{i} 号",
            content: "我是第 #{i} 条评论内容～"
          })

        conn = conn |> put_json_header |> put_authorization(state) |> call
        assert conn.status == 200
        r = conn |> resp_to_map
        assert r.passed
        comment = r.data
        assert comment.owner == false
        comment
      end)

    conn =
      conn(:post, "/comment/admin/add", %{
        article_id: article.id,
        author_email: "me}@bluerain.io",
        author_nickname: "绅士喵",
        content: "我是第一条评论的回复～",
        parent_id: c3.id
      })

    conn = conn |> put_json_header |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    comment = r.data
    assert comment.owner == true

    conn = conn(:get, "/comment/from_article/#{article.id}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 3
    c3 = hd(list)
    assert c3.author_email == "[HIDDEN]"
    c4 = c3.comments |> hd
    assert c4.author_email == "[HIDDEN]"

    conn = conn(:delete, "/comment/admin/#{c3.id}") |> put_authorization(state) |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed

    conn = conn(:get, "/comment/from_article/#{article.id}") |> call
    assert conn.status == 200
    r = conn |> resp_to_map
    assert r.passed
    list = r.data
    assert length(list) == 2
  end
end