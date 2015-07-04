defmodule AssemblaCli do
  alias AssemblaApi.Spaces.SpaceTools
  alias AssemblaApi.Spaces.SpaceTools.MergeRequests
  alias AssemblaApi.Spaces.SpaceTools.MergeRequests.Versions

  @endpoint "https://www.assembla.com"
  @fork "fork"

  def main(args) do
    space = cmd_output "git config assembla.space"
    fork = cmd_output "git config assembla.fork-tool"

    state = %{repo: Gitex.Git.open, space: space, fork_tool: fork, tool: "git"}
    Commands.parse(args) |> exec(state)

    #{opts, _, _} = OptionParser.parse(args, switches: [force: :boolean, compile: :boolean])
    #IO.puts inspect(args)
    #IO.puts inspect(opts)
    #IO.puts inspect(AssemblaApi.Users.me)
  end

  @doc ~S"""
  Transforms API url into web url for browsing MR

  ## Examples

      iex> AssemblaCli.web_url("https://www.assembla.com/v1/spaces/breakout/space_tools/git-58/merge_requests/2027583")
      "https://www.assembla.com/code/breakout/git-58/merge_requests/2027583"

  """
  def web_url(url) do
    url |> String.replace("v1/spaces", "code") |> String.replace("space_tools/", "")
  end

  def exec([{:show_ticket, number} | tail], state) do
    cmd "open #{@endpoint}/spaces/#{state.space}/tickets/#{number}"
    exec(tail, state)
  end

  def exec([:push | tail], state) do
    repo = state.repo
    branch = GitUtils.current_branch(repo)
    IO.puts "Pushing branch #{branch}"
    IO.puts cmd_output("git push -u origin #{branch}")
    exec(tail, state)
  end

  def exec([:new_mr | tail], state) do
    repo = state.repo
    branch = GitUtils.current_branch(repo)

    cmd "git push -u #{@fork} #{branch}"
    %{message: msg} = Gitex.get(branch, repo)
    [subject, body] = String.split msg, "\n", parts: 2
    body = String.strip body
    IO.puts "Branch: #{branch}\nSubject: #{subject}\n\n#{body}"
    {:ok, mr} = MergeRequests.create state.space, state.fork_tool,
      %{title: subject, description: body, source_symbol: branch,
      target_space_tool_id: state.tool, target_symbol: "master"}

    cmd "git config branch.#{branch}.mr #{mr.id}"

    IO.puts mr.url |> web_url

    exec(tail, state)
  end

  def exec([:open_mr | tail], state) do
    branch = GitUtils.current_branch(state.repo)

    mr_id = cmd_output "git config branch.#{branch}.mr"
    cmd "open #{@endpoint}/code/#{state.space}/#{state.fork_tool}/merge_requests/#{mr_id}"

    exec(tail, state)
  end

  def exec([{:new_branch, name} | tail], state) do
    IO.puts "Creating branch #{name}"
    cmd "git checkout -b #{name}"
    exec(tail, state)
  end

  def exec([:new_ver | tail], state) do
    repo = state.repo
    branch = GitUtils.current_branch(repo)

    mr_id = cmd_output "git config branch.#{branch}.mr"

    IO.puts "mr #{mr_id}"

    # 0 = Mix.Shell.cmd "git push #{@fork} #{branch}", fn (data) -> end
    # Versions.create(state.space, state.fork_tool, mr_id)

    exec(tail, state)
  end

  def exec([{:setup, :fork, name} | tail], state) do
    {:ok, tool} = SpaceTools.get(state.space, name)
    cmd "git remote remove fork"
    cmd "git remote add fork #{tool.url}"
    cmd "git config assembla.fork-tool #{name}"
    exec(tail, state)
  end

  def exec([], _state) do
  end

  defp cmd(cmd) do
    f = fn d -> IO.puts d end
    case Mix.Shell.cmd(cmd, f) do
    0 -> :ok
    s -> IO.puts "'#{cmd}' exited with status: #{s}"
    end
  end

  defp cmd_output(cmd) do
    case Mix.Shell.Process.cmd(cmd, []) do
    0 ->
      receive do
        {:mix_shell, :run, [d]} -> d |> String.strip
      end
    s ->
      IO.puts "'#{cmd}' exited with status: #{s}"
    end
  end
end
