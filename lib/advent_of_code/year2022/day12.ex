defmodule AdventOfCode.Year2022.Day12 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> String.to_charlist()
      |> Stream.with_index()
      |> Enum.reduce(map, fn {char, x}, out ->
        new =
          %{{x, y} => char}
          |> Map.merge(
            if char == hd('S') do
              %{:start => {x, y}, {x, y} => hd('a')}
            else
              %{}
            end
          )
          |> Map.merge(
            if char == hd('E') do
              %{:end => {x, y}, {x, y} => hd('z')}
            else
              %{}
            end
          )

        Map.merge(out, new)
      end)
    end)
  end

  def v2_add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def v2_manhattan({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def print_dmap(map, dmap) do
    {xList, yList} =
      map
      |> Enum.filter(fn {_, v} -> is_integer(v) end)
      |> Enum.map_reduce([], fn {{x, y}, _}, yl ->
        {x, [y] ++ yl}
      end)

    {xl, xr} = Enum.min_max([0] ++ xList)
    {yb, yt} = Enum.min_max([0] ++ yList)

    Enum.map(yb..yt, fn y ->
      Enum.map(xl..xr, fn x ->
        case Map.fetch(dmap, {x, y}) do
          {:ok, dist} -> dist
          :error -> -1
        end
      end)
      |> IO.inspect()
    end)
  end

  def print_path(path) do
    {xList, yList} =
      path
      |> Enum.map_reduce([], fn {x, y}, yl ->
        {x, [y] ++ yl}
      end)

    {xl, xr} = Enum.min_max([0] ++ xList)
    {yb, yt} = Enum.min_max([0] ++ yList)

    Enum.map(yb..yt, fn y ->
      Enum.map(xl..xr, fn x ->
        if Enum.member?(path, {x, y}) do
          "!"
        else
          "."
        end
      end)
      |> Enum.join("")
      |> IO.puts()
    end)
  end

  @adjacent [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

  def find_path(map) do
    %{:start => start} = map

    find_path(map, %{}, PriorityQueue.put(PriorityQueue.new(), {1, [start]}))
  end

  defp find_path(map, distMap, pathQueue) do
    {{priority, seen}, pq} = PriorityQueue.pop(pathQueue)
    %{:end => dest} = map

    [current | _] = seen

    cHeight = Map.fetch!(map, current)

    if current == dest do
      seen
    else
      {newQueue, newDists} =
        @adjacent
        |> Stream.map(&v2_add(current, &1))
        |> Stream.filter(fn {x, y} ->
          case Map.fetch(map, {x, y}) do
            {:ok, nHeight} -> !Enum.member?(seen, {x, y}) and nHeight - cHeight <= 1
            :error -> false
          end
        end)
        |> Enum.reduce({pq, distMap}, fn newPos, {queue, dMap} ->
          case Map.fetch(dMap, newPos) do
            {:ok, dist} when priority + 1 <= dist ->
              {PriorityQueue.put(queue, {priority + 1, [newPos] ++ seen}),
               Map.merge(dMap, %{newPos => priority + 1}, fn _, a, b -> min(a, b) end)}

            {:ok, _} ->
              {queue, dMap}

            :error ->
              {PriorityQueue.put(queue, {priority + 1, [newPos] ++ seen}),
               Map.put(dMap, newPos, priority)}
          end
        end)

      if PriorityQueue.size(newQueue) == 0 do
        :error
      else
        find_path(map, newDists, newQueue)
      end
    end
  end

  def part1(input) do
    (input
     |> parse
     |> find_path
     |> length) - 1
  end

  def part2(input) do
    map =
      input
      |> parse

    map
    |> Enum.filter(fn
      # 'S'
      {_, 83} -> true
      # 'a'
      {_, 97} -> true
      _ -> false
    end)
    |> Enum.map(fn {start, _} ->
      %{map | :start => start}
    end)
    |> Enum.map(fn map ->
      Task.async(fn -> map |> find_path end)
    end)
    |> Enum.map(&Task.await(&1))
    |> Enum.filter(&(&1 != :error))
    |> Enum.map(&(length(&1) - 1))
    |> Enum.sort()
    |> hd
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
