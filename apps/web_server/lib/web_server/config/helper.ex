defmodule WebServer.Config.Helper do
  @moduledoc false
  @prefix "ANYEX_SERVER_"
  @config_items [
    {:web_server, :port, :integer},
    {:web_server, :username, :string},
    {:web_server, :password, :string},
    {:web_server, :secret, :string},
    {:web_server, :default_limit, :integer},
    {:web_server, :max_limit, :integer},
    {:web_server, :cors_origins, :string_in_list},
    {:web_server, :markdown_enables, :atom_in_list}
  ]

  def init do
    alias Storage.Schema.SecretSuffix

    configs =
      @config_items
      |> Enum.reduce(Map.new(), fn {app, item, type}, acc ->
        val = get_config!(app, item)

        val = apply(__MODULE__, :"#{type}_conv", [item, val])

        Map.put(acc, gen_key(app, item), val)
      end)

    secret_suffix = SecretSuffix.last_one()
    secret_suffix = secret_suffix || elem(SecretSuffix.generate(), 1)
    configs |> Map.put(gen_key(:web_server, :secret_suffix), secret_suffix.val)
  end

  def string_in_list_conv(item, val) do
    if is_binary(val) do
      val |> String.split(",") |> Enum.map(&String.trim(&1))
    else
      if is_list(val), do: val, else: raise("#{item} needs a list or string value")
    end
  end

  def bool_conv(_item, val) do
    if is_boolean(val), do: val, else: String.to_existing_atom(val)
  end

  def string_conv(_item, val) do
    if is_integer(val), do: Integer.to_string(val), else: val |> String.trim()
  end

  def integer_conv(_item, val) do
    if is_integer(val), do: val, else: val |> String.trim() |> String.to_integer()
  end

  def atom_in_list_conv(item, val) do
    if is_binary(val) do
      list = val |> String.split(",") |> Enum.map(&String.trim(&1))

      list |> Enum.map(&String.to_atom(&1))
    else
      if is_list(val), do: val, else: raise("#{item} needs a list or string value")
    end
  end

  def get_config!(app, item) do
    name = item |> Atom.to_string() |> String.upcase()
    env_var = "#{@prefix}#{name}"

    val =
      System.get_env(env_var) ||
        Application.get_env(app, item)

    if val !== nil, do: val, else: raise("please give me a \"#{item}\" parameter!")
  end

  def gen_key(app, item) do
    "#{app}_#{item}"
  end
end
