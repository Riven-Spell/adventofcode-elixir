defmodule AdventOfCode.Year2022.Day1 do
  def elves(input) do
    input
    |> String.split("\n")
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(
      &(&1
        |> Enum.map(fn x ->
          {n, _} = x |> Integer.parse()
          n
        end))
    )
    |> Stream.map(&Enum.sum(&1))
  end

  def part1(input) do
    input
    |> elves
    |> Enum.reduce(&max(&1, &2))
  end

  def part2(input) do
    input
    |> elves
    |> Enum.reduce(%PriorityQueue{fixedLength: 3}, &PriorityQueue.insert(&2, &1))
    |> PriorityQueue.getList()
    |> Enum.sum()
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
