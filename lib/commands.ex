defmodule Commands do
  @doc ~S"""
  Parse commands from cli args

  ## Examples

      iex> Commands.parse(["new", "mr"])
      [:new_mr]

      iex> Commands.parse(["open", "mr"])
      [:open_mr]

      iex> Commands.parse(["new", "ver"])
      [:new_ver]

      iex> Commands.parse(["and", "t", "503"])
      [{:show_ticket, "503"}]

      iex> Commands.parse(["push"])
      [:push]

      iex> Commands.parse(["setup", "fork", "git-1"])
      [{:setup, :fork, "git-1"}]

      iex> Commands.parse(["f", "ticket_100"])
      [{:new_branch, "ticket_100"}]

  """
  @spec parse(list) :: [term]
  def parse(["new", "mr"| tail]) do
    [:new_mr | parse(tail)]
  end

  def parse(["open", "mr"| tail]) do
    [:open_mr | parse(tail)]
  end

  def parse(["new", "ver"| tail]) do
    [:new_ver | parse(tail)]
  end

  def parse(["setup", "fork", name| tail]) do
    [{:setup, :fork, name} | parse(tail)]
  end

  def parse(["push" | tail]) do
    [:push | parse(tail)]
  end

  def parse(["and" | tail]) do
    parse(tail)
  end

  def parse(["f", name | tail]) do
    [{:new_branch, name} | parse(tail)]
  end

  def parse(["b", name | tail]) do
    [{:new_branch, name} | parse(tail)]
  end

  def parse(["t", number | tail]) do
    [{:show_ticket, number} | parse(tail)]
  end

  # skip bad tokens
  def parse([_| tail]) do
    parse(tail)
  end

  def parse([]) do
    []
  end
end
