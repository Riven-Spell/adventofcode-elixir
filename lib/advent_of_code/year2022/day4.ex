defmodule AdventOfCode.Year2022.Day4 do
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(
      # split pairs
      &(String.split(&1, ",")
        # Get ranges
        |> Enum.map(fn str ->
          # Make numbers alone
          String.split(str, "-")
          # Parse integers
          |> Enum.map(fn x ->
            {n, _} = Integer.parse(x)
            n
          end)
        end)
        # Into ranges
        |> Enum.map(fn [a, b] -> a..b end))
    )
  end

  def rangeContains(sa..ea, sb..eb, inverse \\ false) do
    (sa >= sb && ea <= eb) ||
      (!inverse && rangeContains(sb..eb, sa..ea, true))
  end

  def rangeOverlaps(sa..ea, sb..eb, inverse \\ false) do
    # start of a is between start and end of b
    # end of a is between start and end of b
    (sa >= sb && sa <= eb) ||
      (ea >= sb && ea <= eb) ||
      (!inverse && rangeOverlaps(sb..eb, sa..ea, true))
  end

  def part1(input) do
    input
    |> parse
    |> Enum.count(fn [a, b] ->
      rangeContains(a, b)
    end)
  end

  def part2(input) do
    input
    |> parse
    |> Enum.count(fn [a, b] ->
      rangeOverlaps(a, b)
    end)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
