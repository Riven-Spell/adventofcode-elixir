defmodule AdventOfCode.Year2022.Day8 do
  # Convert from string input to usable 2d array
  def buildMap(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(fn x ->
        {n, _} = Integer.parse(x)
        n
      end)
    end)
  end

  # Judge how many trees are visible from the edge of the array
  def getVisible(row) do
    row
    |> Enum.map_reduce(-1, fn tree, maxHeight ->
      if tree > maxHeight do
        {true, tree}
      else
        {false, maxHeight}
      end
    end)
    |> (fn {list, _} -> list end).()
  end

  # Transpose (x, y) = (y, x)
  def transpose(map) do
    map |> Enum.zip() |> Enum.map(&Tuple.to_list(&1))
  end

  # Judge how many trees are visible from the tree at the head of the array
  def countVisible(_, []) do
    0
  end

  def countVisible(from, [immediate | behind]) do
    if from > immediate do
      # Check the next tree
      1 + countVisible(from, behind)
    else
      # count the immediate tree as visible, because the immediate tree is blocking.
      1
    end
  end

  # Judge how many trees are visible from each tree from the head of the array
  def scenicScores(row) do
    row
    |> Enum.map_reduce([], fn tree, behind ->
      {countVisible(tree, behind), [tree] ++ behind}
    end)
    |> (fn {row, _} -> row end).()
  end

  # Rebuild a map based upon the reduction ("sum") of the map from all 4 directions.
  # Fun is called per-row/column in both directions.
  def remap(map, fun, sumDefault, sumFun) do
    vert_map =
      map
      |> transpose

    left = Enum.map(map, &fun.(&1))
    right = Enum.map(map, &(Enum.reverse(&1) |> fun.() |> Enum.reverse()))
    up = Enum.map(vert_map, &fun.(&1)) |> transpose
    down = Enum.map(vert_map, &(Enum.reverse(&1) |> fun.() |> Enum.reverse())) |> transpose

    [left, right, up, down]
    |> Stream.zip()
    |> Stream.map(
      &(Tuple.to_list(&1)
        |> Enum.zip()
        |> Enum.map(fn x -> x |> Tuple.to_list() |> Enum.reduce(sumDefault, sumFun) end))
    )
  end

  def part1(input) do
    input
    |> buildMap
    # remap to visibility
    |> remap(&getVisible(&1), false, fn x, acc -> x || acc end)
    # count visible trees
    |> Enum.reduce(0, fn x, acc -> acc + Enum.count(x, &(&1 == true)) end)
  end

  def part2(input) do
    input
    |> buildMap
    # remap to scenic scores
    |> remap(&scenicScores(&1), 1, fn x, acc -> x * acc end)
    # find most scenic tree
    |> Stream.map(&Enum.max(&1))
    |> Enum.max()
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
