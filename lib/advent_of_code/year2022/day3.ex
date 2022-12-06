defmodule AdventOfCode.Year2022.Day3 do
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(&String.to_charlist(&1))
  end

  def sharedChars(a, b) do
    MapSet.intersection(
      MapSet.new(a),
      MapSet.new(b)
    )
    |> MapSet.to_list()
  end

  def priority(a) do
    if a > 0x61 do
      a - 0x60
    else
      a - 0x40 + 26
    end
  end

  def part1(input) do
    input
    |> parse
    |> Stream.map(fn x ->
      len = length(x)
      # Break strings in half
      Enum.split(x, div(len, 2))
    end)
    |> Stream.map(fn {a, b} ->
      # Find common item between sides
      sharedChars(a, b) |> hd |> priority
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse
    # split into groups of 3
    |> Stream.chunk_every(3)
    |> Stream.map(fn list ->
      # determine the shared character by reducing
      list
      |> Enum.reduce(&sharedChars(&1, &2))
      |> hd
      |> priority
    end)
    # Sum for the solution
    |> Enum.sum()
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
