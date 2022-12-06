defmodule AdventOfCode.Year2022.Day2 do
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(
      &(String.split(&1, " ")
        |> Enum.map(fn x -> x |> String.to_charlist() |> hd end)
        |> List.to_tuple())
    )
    |> Stream.map(fn x ->
      {a, b} = x
      {a - 64, b - 87}
    end)
  end

  def game(turn) do
    score =
      case turn do
        {a, a} -> 3
        {3, 1} -> 6
        {a, b} when a == b - 1 -> 6
        _ -> 0
      end

    {_, playpts} = turn
    score + playpts
  end

  def part1(input) do
    input
    |> parse
    |> Stream.map(&game(&1))
    |> Enum.sum()
  end

  defp findMove({enemy, target}) do
    newMove = enemy + (target - 2)

    case newMove do
      # handle bounds
      0 -> {enemy, 3}
      4 -> {enemy, 1}
      x -> {enemy, x}
    end
  end

  def part2(input) do
    input
    |> parse
    |> Stream.map(&findMove(&1))
    |> Stream.map(&game(&1))
    |> Enum.sum()
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
