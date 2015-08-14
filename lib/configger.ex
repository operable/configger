# -------------------------------------------------------------------
#
# configger: Mix task to simplify building OTP configurations
#
# Copyright (c) 2015 Operable, Inc. All Rights Reserved.
#
# This file is provided to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain
# a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# -------------------------------------------------------------------

defmodule Mix.Tasks.Configger do

  use Mix.Task

  @shortdoc "Converts Mix config into proplist format expected by OTP"

  @moduledoc """
  A task which converts Mix-style application config into OTP format.

  ## Command line options

    * `--config`         - Path to mix.exs (defaults to `config/mix.exs`)
    * `--output`         - Path to write sys.config (defaults to current directory)

  """

  @required [:config, :output]

  def run(args) do
    run_with_args(OptionParser.parse(args))
  end

  defp run_with_args({args, _, _}) do
    [config: config, output: output] = populate_defaults(args)
    output = Path.join(output, "sys.config")
    mix_config = Mix.Config.read!(config)
    case :file.write_file(output, :io_lib.format('~p', [mix_config])) do
      :ok ->
        Mix.Shell.IO.info("Successfully generated #{output}")
      error ->
        Mix.raise("Error generating #{output} from #{config}: #{s(:file.format_error(error))}")
    end
  end

  defp populate_defaults(args) do
    reducer = fn(arg, accum) -> ensure_defaults(arg, args, accum) end
    Enum.reduce(@required, [], reducer) |> Enum.sort
  end

  defp ensure_defaults(arg, args, accum) do
    case Keyword.fetch(args, arg) do
      :error ->
        accum ++ [{arg, default_value(arg)}]
      {:ok, ""} ->
        accum ++ [{arg, default_value(arg)}]
      {:ok, value} ->
        accum ++ [{arg, value}]
    end
  end

  defp default_value(:config), do: "config/config.exs"
  defp default_value(:output) do
    {:ok, working_dir} = File.cwd
    working_dir
  end

  defp s(text) when is_list(text), do: to_string(text)

end
