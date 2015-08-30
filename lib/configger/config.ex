defmodule Configger.Config do

  defmacro __using__(_) do
    quote do
      use Mix.Config
      import Configger.Config, only: [env: 1,
                                      env: 2,
                                      default: 1]
    end
  end

  defmacro env(name) do
    quote do
      envvar = unquote(name)
      [_, varname] = String.split("#{envvar}", "Elixir.")
      dvalue = &Configger.Config.identity/1
      dvalue.(System.get_env(varname))
    end
  end

  defmacro env(name, dvalue) do
    quote do
      envvar = unquote(name)
      [_, varname] = String.split("#{envvar}", "Elixir.")
      unquote(dvalue).(System.get_env(varname))
    end
  end

  def default(value) when is_integer(value) do
    make_evaluator(value, &String.to_integer/1)
  end
  def default(value) when is_float(value) do
    make_evaluator(value, &String.to_float/1)
  end
  def default(value) when is_list(value) do
    make_evaluator(value, fn(v) -> String.split(v, ":") end)
  end
  def default(value) when is_binary(value) do
    make_evaluator(value, &identity/1)
  end

  def identity(v), do: v

  defp make_evaluator(value, converter) do
    fn(envval) ->
      case envval do
        nil ->
          value
        _ ->
          converter.(envval)
      end
    end
  end

end
