defmodule Storage.Schema.Category do
  @moduledoc false
  use Storage.Schema

  alias Storage.Repo
  alias Storage.Schema.{Article}
  alias Ecto.{Changeset}

  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder, only: [:id, :path, :name, :description, @top_field] ++ @common_fields}
  schema "category" do
    field :path
    field :name
    field :description, :string, default: "none"

    top_field(:v001)
    common_fields(:v001)

    has_many :articles, Article
  end

  @impl Storage.Schema
  def changeset(category, data \\ %{}) do
    category
    |> Changeset.cast(data, [:path, :name, :description, :top, @status_field])
    |> Changeset.validate_required([:path, :name, :top, @status_field])
  end

  def add(data), do: add(%__MODULE__{}, data)

  def update(data) do
    guaranteed_id data do
      category = Repo.get(__MODULE__, data.id)
      category |> update(data)
    end
  end

  def find_list(filters \\ []) when is_list(filters) do
    query =
      from c in __MODULE__,
        order_by: [desc: c.top]

    query =
      Enum.reduce(filters, query, fn {key, value}, acc_query ->
        if value == nil do
          acc_query
        else
          case key do
            :res_status ->
              from c in acc_query,
                where: c.res_status == ^value

            :limit ->
              from _ in acc_query,
                limit: ^value

            :offset ->
              from _ in acc_query,
                offset: ^value

            _ ->
              acc_query
          end
        end
      end)

    query |> query_list
  end

  def top(id) do
    top(__MODULE__, id)
  end
end
