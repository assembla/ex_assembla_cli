defmodule Mix.Tasks.RunEscript do
  use Mix.Task

  @shortdoc "Build and run escript"
  def run(args) do
    Mix.Tasks.Escript.Build.run(args)

    case Mix.shell.cmd("./assembla_cli") do
      0 -> :ok
      s -> exit(s)
    end
  end
end
