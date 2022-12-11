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

  def sign(x) do
    if x == 0 do
      0
    else
      div(abs(x), x)
    end
  end

  def correct_tail_segments(_, _, []) do
    []
  end

  # Recursively correct tail
  def correct_tail_segments({hx, hy}, [{tx, ty} | remainder]) do
    newTail =
      case {tx, ty} do
        # Stay (adjacent)
        {_, _} when not (abs(hx - tx) > 1 or abs(hy - ty) > 1) ->
          {tx, ty}

        # Stay (same)
        {^hx, ^hy} ->
          {tx, ty}

        # Move towards
        {_, _} ->
          diffx = hx - tx
          diffy = hy - ty
          {tx + sign(diffx), ty + sign(diffy)}
      end

    [newTail] ++ correct_tail_segments(newTail, {tx, ty}, remainder)
  end

  def performMove(string, {_, count}, tailSeen) when count <= 0 do
    {string, tailSeen}
  end

  # Recursively handle move steps & write to seen places
  def performMove({head, tail}, {move, count}, tailSeen) do
    new_head = v2_add(head, move)
    new_tail = correct_tail_segments(new_head, tail)

    #    {new_head, new_tail} |> printString

    performMove(
      {new_head, new_tail},
      {move, count - 1},
      MapSet.put(tailSeen, hd(new_tail |> Enum.reverse()))
    )
  end

  def initString(length) do
    {{0, 0}, Stream.repeatedly(fn -> {0, 0} end) |> Enum.take(length - 1)}
  end

  def printString({head, tail}) do
    map =
      ([head] ++ tail)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {coord, idx}, acc ->
        Map.put(acc, coord, idx)
      end)

    {xList, yList} =
      ([head] ++ tail)
      |> Enum.map_reduce([], fn {x, y}, yl ->
        {x, [y] ++ yl}
      end)

    {xl, xr} = Enum.min_max([0] ++ xList)
    {yb, yt} = Enum.min_max([0] ++ yList)

    Enum.map(yt..yb, fn y ->
      Enum.map(xl..xr, fn x ->
        case Map.fetch(map, {x, y}) do
          _ when {x, y} == {0, 0} -> "s"
          {:ok, idx} -> Integer.to_string(idx)
          :error -> "."
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end)

    "====================\n\n" |> IO.puts()
  end

  def runWithLength(input, length) do
    input
    |> parseInstructions
    |> Enum.reduce({initString(length), MapSet.new()}, fn move, {string, seen} ->
      performMove(string, move, seen)
    end)
    |> (fn {_, seen} -> seen end).()
    |> MapSet.size()
  end

  def part1(input) do
    input |> runWithLength(2)
  end

  def part2(input) do
    input |> runWithLength(10)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
