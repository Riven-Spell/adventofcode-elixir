defmodule AdventOfCode.Year2022.Day13 do
  def parse_item(item) do
    case Integer.parse(item) do
      {n, ""} ->
        n

      :error when item != "" ->
        parse_list(item)
    end
  end

  def parse_list(line) do
    line
    |> String.split("", trim: true)
    |> Enum.reduce({[], "", 0}, fn char, {out, currentItem, level} ->
      case char do
        " " when level == 1 ->
          {out, currentItem, level}

        "," when level == 1 ->
          {out ++ [parse_item(currentItem)], "", level}

        "[" when level == 0 ->
          {out, currentItem, level + 1}

        "]" when level == 1 ->
          {out, currentItem, level - 1}

        "[" ->
          {out, currentItem <> char, level + 1}

        "]" ->
          {out, currentItem <> char, level - 1}

        _ ->
          {out, currentItem <> char, level}
      end
    end)
    |> (fn {out, currentItem, level} ->
          if level != 0 do
            raise "Level must be 0, but is " <> Integer.to_string(level)
          end

          if currentItem != "" do
            out ++ [parse_item(currentItem)]
          else
            out
          end
        end).()
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(
      &(String.split(&1, "\n", trim: true)
        |> Enum.map(fn x -> parse_list(x) end)
        |> List.to_tuple())
    )
  end

  def packets_in_order?(sides) do
    case sides do
      # if one side is shorter than the other
      {[_ | _], []} ->
        false

      {[], [_ | _]} ->
        true

      # if both packets are the same length
      {[], []} ->
        :orderless

      # if both sides are integers
      {[left | lrem], [right | rrem]} when is_integer(left) and is_integer(right) ->
        if left < right do
          true
        else
          if left == right do
            packets_in_order?({lrem, rrem})
          else
            false
          end
        end

      # if both sides are lists
      {[left | lrem], [right | rrem]} when is_list(left) and is_list(right) ->
        case packets_in_order?({left, right}) do
          :orderless -> packets_in_order?({lrem, rrem})
          order -> order
        end

      # if one side is an integer but not the other
      {[left | lrem], [right | rrem]} when is_list(left) and is_integer(right) ->
        case packets_in_order?({left, [right]}) do
          :orderless -> packets_in_order?({lrem, rrem})
          order -> order
        end

      {[left | lrem], [right | rrem]} when is_integer(left) and is_list(right) ->
        case packets_in_order?({[left], right}) do
          :orderless -> packets_in_order?({lrem, rrem})
          order -> order
        end
    end
  end

  def part1(input) do
    input
    |> parse
    |> Enum.with_index()
    |> Enum.reduce(0, fn {lists, index}, sum ->
      if packets_in_order?(lists) == true do
        sum + index + 1
      else
        sum
      end
    end)
  end

  def part2(input) do
    packets =
      (input
       |> parse
       |> Enum.flat_map(fn {l, r} -> [l, r] end)) ++ [[[2]], [[6]]]

    packets
    |> Enum.sort(&packets_in_order?({&1, &2}))
    |> Stream.with_index()
    |> Enum.reduce(1, fn {list, idx}, acc ->
      case list do
        [[2]] -> acc * (idx + 1)
        [[6]] -> acc * (idx + 1)
        _ -> acc
      end
    end)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
