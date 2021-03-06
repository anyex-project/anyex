defmodule Storage.Schema.ArticleTest do
  use ExUnit.Case, async: false

  alias Storage.Repo
  alias Storage.Schema.{Article, Category, Tag}

  import Storage.Schema.Article

  require Integer

  setup do
    on_exit(fn ->
      Repo.delete_from!(:articles_tags)
      Repo.delete_all(Article)
      Repo.delete_all(Tag)
      Repo.delete_all(Category)
    end)
  end

  test "add and update article" do
    {status, category} = Category.add(%{path: "c1", name: "类别1"})
    assert status == :ok

    {status, tag1} = Tag.add(%{path: "t1", name: "标签1"})
    assert status == :ok
    {status, tag2} = Tag.add(%{path: "t2", name: "标签2"})
    assert status == :ok

    {status, article} =
      add(%{path: "first-article", title: "第一篇文章", category_id: category.id, tags: [tag1, tag2]})

    assert status == :ok
    assert article.category_id == category.id
    assert length(article.tags) == 2

    article = Map.merge(%{id: article.id}, %{title: "修改后的文章", tags: [%{id: tag1.id}]})
    {status, article} = update(article)
    assert status == :ok
    assert article.category_id == category.id
    assert length(article.tags) == 1
    assert Enum.at(article.tags, 0).id == tag1.id
  end

  test "find article list" do
    {status, category} = Category.add(%{path: "default", name: "默认类别"})
    assert status == :ok

    {status, tag1} = Tag.add(%{path: "t1", name: "标签1"})
    assert status == :ok
    {status, tag2} = Tag.add(%{path: "t2", name: "标签2"})
    assert status == :ok

    created_list =
      1..15
      |> Enum.map(fn i ->
        article = %{
          path: "first-article-#{i}",
          title: "第 #{i} 篇文章",
          category_id: category.id,
          tags: []
        }

        article =
          if Integer.is_odd(i),
            do: %{article | tags: [%{id: tag1.id}]},
            else: %{article | tags: [%{id: tag2.id}]}

        {status, article} = article |> add()

        assert status == :ok
        assert article.category_id == category.id

        article
      end)

    {status, list} = find_list()
    assert status == :ok
    assert length(list) == 15

    {status, list} = find_list(tag_path: "t2", res_status: 1)
    assert status == :ok
    assert length(list) == 7

    article = Map.merge(Enum.at(created_list, 0), %{res_status: -1})
    {status, _article} = update(article)
    assert status == :ok
    {status, list} = find_list(res_status: 1)
    assert status == :ok
    assert length(list) == 14

    {status, list} = find_list(offset: 13, res_status: 1)
    assert status == :ok
    assert length(list) == 1
  end

  test "find article" do
    {status, category} = Category.add(%{path: "default", name: "默认类别"})
    assert status == :ok

    {status, tag1} = Tag.add(%{path: "t1", name: "标签1"})
    assert status == :ok
    {status, tag2} = Tag.add(%{path: "t2", name: "标签2"})
    assert status == :ok

    {status, article} =
      add(%{
        path: "first-article",
        title: "第一篇文章",
        category_id: category.id,
        tags: [%{id: tag1.id}, %{id: tag2.id}]
      })

    assert status == :ok
    assert article.category_id == category.id

    {status, article} = find(path: "first-article", res_status: 1)
    assert status == :ok
    assert article.title == "第一篇文章"

    {status, _article} = update(%{id: article.id, res_status: -1})
    assert status == :ok
    {status, article} = find(path: "first-article", res_status: 1)
    assert status == :ok
    assert article == nil
  end
end
