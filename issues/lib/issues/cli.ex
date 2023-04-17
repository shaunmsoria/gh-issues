defmodule Issues.CLI do
  require IEx
  @default_count 4
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """
  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [count | #{@default_count}]
    """)

    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)

    # |> last2(count)
  end

  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse()
  end

  # For the display exercise
  # Enum.reduce([map], acc, fun) |> IO.inspect()
  # with acc being set as the header could work
  # Enum.at(map, index)["created_at"]
  # Enum.at(map, index)["id"]
  # Enum.at(map, index)["title"]

  def test_format() do
    {:ok, data} = Issues.GithubIssues.fetch("elixir-lang", "elixir")

    # format_github(data)

    # id_format(4466464646, )

    format_header(data)

    # max_length(id_list(data))
  end

  def id_list(list), do: Enum.map(list, fn elem -> "#{elem["id"]}" end)

  def max_length(list) do
    for elem <- list do
      elem |> String.length()
    end
    |> Enum.max()
  end

  def elem_format(elem, elem_max_length), do: String.pad_trailing("#{elem}", elem_max_length, " ")

  def format_header(list) do
    id_max_length = max_length(id_list(list))

    date_max_length =
      max_length(Enum.at(list, 0)["created_at"])
      |> IO.inspect()
  end

  def format_github(list) do
    id_max_length = max_length(id_list(list))

    Enum.reduce(
      list,
      " # | created_at | title             \n",
      fn map_issue, acc ->
        date = map_issue["created_at"]
        id = map_issue["id"]
        id_format = elem_format(id, id_max_length)
        title = map_issue["title"]

        acc <> "#{id_format} | #{date} | #{title} \n"
      end
    )
    |> IO.puts()
  end

  # book exercise
  # def t_last() do
  #   last2(["e", "d", "c", "b", "a"], 3)
  #   |> IO.inspect()
  # end

  # def last2([], _count), do: []
  # def last2(_list, 0), do: []
  # def last2([head | tail], count), do: last2(tail, count - 1) ++ [head]

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end
end
