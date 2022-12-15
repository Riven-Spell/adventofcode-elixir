defmodule AdventOfCode.Year2022.Day14 do
  def getLine({sx, sy}, {ex, ey}) do
    if sx == ex do
      Enum.map(sy..ey, fn y -> {sx, y} end)
    else
      Enum.map(sx..ex, fn x -> {x, sy} end)
    end
  end

  def buildMap([]) do
    %{}
  end

  def buildMap([next | rem]) do
    out =
      next
      |> Enum.reduce(%{}, fn {s, e}, map ->
        getLine(s, e)
        |> Enum.reduce(map, fn idx, map ->
          Map.put(map, idx, :rock)
        end)
      end)

    Map.merge(out, buildMap(rem))
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split(" -> ", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y] ->
        {x, _} = Integer.parse(x)
        {y, _} = Integer.parse(y)

        {x, y}
      end)
      |> Enum.reduce({[], nil}, fn current, {out, last} ->
        if last == nil do
          {[], current}
        else
          {out ++ [{last, current}], current}
        end
      end)
      |> (fn {out, _} -> out end).()
    end)
  end

  def printMap(map) do
    {xList, yList} =
      map
      |> Enum.map_reduce([], fn {{x, y}, _}, yl ->
        {x, [y] ++ yl}
      end)

    {xl, xr} = Enum.min_max(xList)
    {yb, yt} = Enum.min_max([0] ++ yList)

    padding = length(Integer.digits(max(xl, xr))) + 1

    Enum.map(xl..xr, fn x -> Integer.to_string(x) |> String.split("", trim: true) end)
    |> Enum.zip()
    |> Enum.map(fn t ->
      t
      |> Tuple.to_list()
      |> Enum.join("")
      |> (fn line ->
            String.pad_leading("", padding) <> line
          end).()
    end)
    |> Enum.join("\n")
    |> IO.puts()

    Enum.map(yb..yt, fn y ->
      Enum.map(xl..xr, fn x ->
        case Map.fetch(map, {x, y}) do
          {:ok, :rock} -> "#"
          {:ok, :sand} -> "o"
          :error -> "."
        end
      end)
      |> Enum.join("")
      |> (fn str -> (Integer.to_string(y) |> String.pad_trailing(padding)) <> str end).()
      |> IO.puts()
    end)

    nil
  end

  def findVoid(map) do
    map
    |> Enum.reduce(0, fn {{_, y}, _}, max ->
      if y > max do
        y
      else
        max
      end
    end)
  end

  @movePattern [0, -1, 1]

  def placeSand(map, bottom, voiding) do
    bottom =
      if voiding do
        bottom
      else
        bottom + 1
      end

    resting =
      1..bottom
      |> Enum.reduce_while({500, 0}, fn y, {xacc, yacc} ->
        validSpots =
          @movePattern
          |> Enum.map(&{xacc + &1, y})
          |> Enum.filter(&(not Map.has_key?(map, &1)))

        if validSpots == [] do
          {:halt, {xacc, yacc}}
        else
          {:cont, hd(validSpots)}
        end
      end)

    case resting do
      {_, ^bottom} when voiding -> :void
      {500, 0} -> :blocked
      _ -> Map.put(map, resting, :sand)
    end
  end

  def placeUntilVoid(map, void) do
    case placeSand(map, void, true) do
      :void -> map
      newMap -> placeUntilVoid(newMap, void)
    end
  end

  def placeUntilBlocked(map, void) do
    case placeSand(map, void, false) do
      :blocked -> map
      newMap -> placeUntilBlocked(newMap, void)
    end
  end

  def part1(input) do
    map = input |> parse |> buildMap
    void = map |> findVoid

    placeUntilVoid(map, void)
    #    |> Enum.count(fn {{_, _}, value} -> value == :sand end)
    |> printMap
  end

  def part2(input) do
    map = input |> parse |> buildMap
    void = map |> findVoid

    placeUntilBlocked(map, void)
    |> Map.put({500, 0}, :sand)
    |> printMap

    # 	  |> Enum.count(fn {{_, _}, value} -> value == :sand end)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
