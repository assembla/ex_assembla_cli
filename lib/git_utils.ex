defmodule GitUtils do
  #
  def refs(repo) do
    base_path = [repo.home_dir, "refs", "heads"] |> Path.join
    ref_paths = [base_path, "**"] |> Path.join |> Path.wildcard |> Enum.map fn (path) ->
      {path |> String.replace(base_path<>"/", ""), File.read!(path) |> String.strip}
    end

    {_, map} = Enum.map_reduce(ref_paths, %{}, fn ({k,v}, acc) -> {"",Dict.put(acc, k, v)} end)
    map
  end

  def current_branch(repo) do
    repo.home_dir |> Path.join("HEAD") |> File.read! |> String.strip |> String.replace("ref: refs/heads/", "")
  end
end
