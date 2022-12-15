defmodule AdventOfCode.Year2022.Day15 do
  @line_regex ~r/Sensor at x=(?<sx>-?\d+), y=(?<sy>-?\d+): closest beacon is at x=(?<bx>-?\d+), y=(?<by>-?\d+)/

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.named_captures(@line_regex, &1))
    |> Enum.map(fn %{"sx" => sx, "sy" => sy, "bx" => bx, "by" => by} ->
      {sx, _} = Integer.parse(sx)
      {sy, _} = Integer.parse(sy)
      {bx, _} = Integer.parse(bx)
      {by, _} = Integer.parse(by)
      {{sx, sy}, {bx, by}}
    end)
  end

  def beacon_set(sensors) do
    sensors
    |> Enum.reduce(MapSet.new(), fn {_, beacon}, ms -> MapSet.put(ms, beacon) end)
  end

  def v2_manhattan({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  def find_empty([], _) do
    []
  end

  def find_empty([{{sx, sy}, beacon} | rem], row) do
    max_dist = v2_manhattan({sx, sy}, beacon)
    base_dist = v2_manhattan({sx, sy}, {sx, row})
    rem_dist = max_dist - base_dist

    out =
      if rem_dist >= 0 do
        [(sx - rem_dist)..(sx + rem_dist)]
      else
        []
      end

    out ++ find_empty(rem, row)
  end

  def collapse_ranges(ranges) do
    ranges
    |> Enum.sort()
    |> Enum.reduce([], fn
      range, [] ->
        [range]

      range, [last | rem] ->
        if Range.disjoint?(range, last) do
          [range, last] ++ rem
        else
          l..r = range
          ll..lr = last
	        [Enum.min([l, r, ll, lr])..Enum.max([l, r, ll, lr])] ++ rem
        end
    end)
    |> Enum.sort()
  end

  def remove_from_range(l..r, beacon) do
    l..r = min(l, r)..max(l, r)

    case beacon do
      ^l -> [(l + 1)..r]
      ^r -> [l..(r - 1)]
      # we want the furthest range on the head so it can be re-used
      _ when l < beacon and beacon < r -> [(beacon + 1)..r, l..(beacon - 1)]
      _ -> l..r
    end
  end

  def remove_beacons_from_ranges(ranges, beacons, row) do
    # reduce to beacons to worry about
    beacons =
      beacons
      |> Enum.filter(fn
        {_, ^row} -> true
        _ -> false
      end)
      |> Enum.reduce(MapSet.new(), fn {x, _}, acc -> MapSet.put(acc, x) end)

    ranges
    |> Enum.flat_map(fn l..r ->
      # first, make the range usable
      l..r = min(l, r)..max(l, r)

      beacons
      |> Enum.filter(fn x -> l <= x or x <= r end)
      |> Enum.sort()
      |> Enum.reduce([], fn
        beacon, [] when beacon != l and beacon != r ->
          remove_from_range(l..r, beacon)

        beacon, [ll..lr | rem] ->
          remove_from_range(ll..lr, beacon) ++ rem
      end)
    end)
  end

  def part1(input, row \\ 2_000_000) do
    sensors =
      input
      |> parse

    beacons = beacon_set(sensors)

    find_empty(sensors, row)
    |> collapse_ranges
    |> remove_beacons_from_ranges(beacons, row)
    |> Enum.reduce(0, fn range, sum -> sum + Range.size(range) end)
  end

  def reduce_range(l..r, tl..tr) do
	  l..r = min(l, r)..max(l, r)
	  tl..tr = min(tl, tr)..max(tl, tr)

	  if Range.disjoint?(l..r, tl..tr) do
		  :none
	  else
	    l = if l < tl do
		    tl
	    else
	      l
	    end

	    r = if r > tr do
		    tr
	    else
	      r
	    end

	    l..r
	  end
  end

  def part2(input, max \\ 4_000_000) do
	  sensors =
		  input
		  |> parse

	  0..max
	  |> Enum.map(fn row ->
		  find_empty(sensors, row)
		  |> collapse_ranges
	  end)
	  |> Enum.map(fn ranges ->
	    ranges
	    |> Enum.map(&reduce_range(&1, 0..max))
	    |> Enum.reduce(nil, fn
          range, nil -> {[], range}
          l..r, {seen, ll..lr} -> # these are sorted, so lr will be prior to l
            if l == lr + 1 do
	            {seen, l..r}
            else
	            {((lr + 1)..(l - 1) |> Enum.take(max)) ++ seen, l..r}
            end
         end)
	    |> (fn {seen, _} -> seen end).()
	  end)
	  |> Enum.with_index()
	  |> Enum.flat_map(fn {seen, idx} ->
	    Enum.map(seen, &((&1 * 4000000) + idx))
	  end) # there should only be one... in theory.
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
