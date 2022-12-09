defmodule AdventOfCode.Year2022.Day9 do
	def dirToMove(dir) do
		case dir do
			"U" -> {0, 1}
			"D" -> {0, -1}
			"L" -> {-1, 0}
			"R" -> {1, 0}
		end
	end

	def parseInstructions(input) do
		input
		|> String.split("\n", trim: true)
		|> Stream.map(&Regex.named_captures(~r/^(?<dir>.) (?<count>\d+)$/, &1))
		|> Stream.map(fn %{"count" => count, "dir" => dir} ->
			{n, _} = Integer.parse(count)
			{dirToMove(dir), n}
		end)
	end

	def v2_add({x1, y1}, {x2, y2}) do
		{x1 + x2, y1 + y2}
	end

	def correct_tail({hx, hy}, oldHead, {tx, ty}) do
		if abs(hx - tx) > 1 or abs(hy - ty) > 1 do
			oldHead
		else
			{tx, ty}
		end
	end

	def performMove(string, {_, count}, tailSeen) when count <= 0 do
		{string, tailSeen}
	end

	def performMove({head, tail}, {move, count}, tailSeen) do
		new_head = v2_add(head, move)
		new_tail = correct_tail(new_head, head, tail)

		performMove({new_head, new_tail}, {move, count - 1}, MapSet.put(tailSeen, new_tail))
	end

  def part1(input) do
	  input
	  |> parseInstructions
	  |> Enum.reduce({{{0, 0}, {0, 0}}, MapSet.new()}, fn move, {string, seen} ->
	    performMove(string, move, seen)
	  end)
	  |> (fn {_, seen} -> seen end).()
	  |> MapSet.size
  end

  def part2(input) do
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
