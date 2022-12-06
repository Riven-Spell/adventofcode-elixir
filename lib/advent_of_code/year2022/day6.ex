defmodule AdventOfCode.Year2022.Day6 do
	def find_unique(input, count) do
		input
		|> String.to_charlist
		|> Stream.unfold(fn
			[] -> nil
			str -> {hd(str), tl(str)}
		end)
		|> Stream.with_index
		|> Enum.reduce(Deque.new(count), fn {char, idx}, acc ->
			if is_integer(acc) do
				acc
			else
				if MapSet.new(acc) |> MapSet.size == count do
					idx
				else
					acc |> Deque.appendleft(char)
				end
			end
		end)
	end

  def part1(input) do
		input |> find_unique(4)
  end

  def part2(input) do
		input |> find_unique(14)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
