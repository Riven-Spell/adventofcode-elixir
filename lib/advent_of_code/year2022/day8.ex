defmodule AdventOfCode.Year2022.Day8 do
	def buildMap(input) do
		input
		|> String.split("\n", trim: true)
		|> Enum.map(fn line ->
			line
			|> String.split("", trim: true)
			|> Enum.map(fn x -> {n, _} = Integer.parse(x); n end)
		end)
	end

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

	def invert(map) do
		map |> Enum.zip() |> Enum.map(&Tuple.to_list(&1))
	end

  def part1(input) do
	  horiz_map = input
    |> buildMap

	  vert_map = horiz_map
	  |> invert

	  left = Enum.map(horiz_map, fn row ->
	    getVisible(row)
	  end)

	  right = Enum.map(horiz_map, fn row ->
	    Enum.reverse(row) |> getVisible |> Enum.reverse()
	  end)

	  top = Enum.map(vert_map, fn row ->
	    getVisible(row)
	  end) |> invert

	  bottom = Enum.map(vert_map, fn row ->
		  Enum.reverse(row) |> getVisible |> Enum.reverse()
	  end) |> invert

	  [left, right, top, bottom]
	  |> Stream.zip()
	  |> Stream.map(&Tuple.to_list(&1)|> Enum.zip |> Enum.map(fn {l, r, t, b} -> l || r || t || b end))
	  |> Enum.reduce(0, fn x, acc -> acc + Enum.count(x, &(&1 == true)) end)

#	  top = Enum.map()
#	  vertical_map = horizontal_map |> Enum.zip() |> Enum.map(&Tuple.to_list(&1))
  end

  def countVisible(from, []) do
		0
  end

  def countVisible(from, [immediate | behind]) do
	  if from > immediate do
		  1 + countVisible(from, behind) # Check the next tree
	  else
	    1 # count the immediate tree as visible, because the immediate tree is blocking.
	  end
  end

  def scenicScores(row) do
		row
		|> Enum.map_reduce([], fn tree, behind ->
			{countVisible(tree, behind), [tree] ++ behind}
		end)
		|> (fn {row, _} -> row end).()
  end

  def part2(input) do
		horiz_map = input
		            |> buildMap

		vert_map = horiz_map
		           |> invert

		left = Enum.map(horiz_map, &scenicScores(&1))
		right = Enum.map(horiz_map, &Enum.reverse(&1) |> scenicScores() |> Enum.reverse)
		up = Enum.map(vert_map, &scenicScores(&1)) |> invert
		down = Enum.map(vert_map, &Enum.reverse(&1) |> scenicScores() |> Enum.reverse) |> invert

		[left, right, up, down]
		|> Stream.zip()
		|> Stream.map(&Tuple.to_list(&1)|> Enum.zip |> Enum.map(fn {l, r, t, b} -> l * r * t * b end))
		|> Stream.map(&Enum.max(&1))
		|> Enum.max
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
