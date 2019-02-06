defmodule WebServer.Routes.ArticleRouter do
  @moduledoc false
  alias Storage.Schema.{Article}

  use WebServer.Router,
    schema: Article,
    include: [:list, :admin_list, :admin_add, :admin_update, :status_manage, :top]

  use WebServer.RouterHelper, :default_routes
end
