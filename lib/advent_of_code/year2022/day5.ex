defmodule AdventOfCode.Year2022.Day5 do
  # If you ignore this hellscape, the solution is actually pretty clean!
  def parse(input) do
    [stacks, instructions] =
      input
      |> String.trim_trailing()
      |> String.split(~r/\n(\s?\d+\s+)+\n\n/)
      |> Enum.map(&String.split(&1, "\n"))

    parsed_stacks =
      stacks
      |> Enum.map( # Break into
        &(Stream.unfold(&1, fn x -> String.split_at(x, 4) end)
          |> Enum.take_while(fn x -> x != "" end)
          |> Enum.map(fn x -> String.trim(x) |> String.trim("[") |> String.trim("]") end))
      )
      |> Enum.zip_reduce([], fn x, acc ->
        acc ++ [Enum.filter(x, &(&1 != "")) |> List.to_tuple()]
      end)
      |> Enum.map(&Tuple.to_list(&1))
      |> Enum.with_index()
      # map it, because LL sucks for this
      |> Enum.reduce(%{}, fn {x, index}, acc ->
        Map.put_new(acc, index + 1, x)
      end)

    parsed_instructions =
      instructions
      |> Enum.map(fn x ->
        String.split(x, ~r/\s?(move|from|to)\s?/, trim: true)
        |> Enum.map(fn x ->
          {n, _} = Integer.parse(x)
          n
        end)
        |> List.to_tuple()
      end)

    {parsed_stacks, parsed_instructions}
  end

  def perform_instructions({stacks, instructions}, stepped) do
    perform_instructions(stacks, instructions, stepped)
  end

  def perform_instructions(stacks, instructions, stepped) do
    instructions
    |> Enum.reduce(stacks, fn x, acc ->
      if stepped do
        perform_instruction(acc, x)
      else
        perform_instruction_whole(acc, x)
      end
    end)
  end

  def perform_instruction_whole(stacks, {count, from, to}) do
    Map.put(stacks, to, Enum.take(Map.fetch!(stacks, from), count) ++ Map.fetch!(stacks, to))
    |> Map.put(from, Enum.drop(Map.fetch!(stacks, from), count))
  end

  def perform_instruction(stacks, {steps, from, to}) when steps > 0 do
    stacks =
      Map.put(stacks, to, [hd(Map.fetch!(stacks, from))] ++ Map.fetch!(stacks, to))
      |> Map.put(from, tl(Map.fetch!(stacks, from)))

    # recurse
    perform_instruction(stacks, {steps - 1, from, to})
  end

  def perform_instruction(stacks, {steps, _, _}) when steps <= 0 do
    stacks
  end

  def part1(input) do
    out =
      input
      |> parse
      |> perform_instructions(true)

    len = out |> Map.keys() |> length

    Enum.reduce(1..len, "", fn idx, acc ->
      acc <> hd(Map.fetch!(out, idx))
    end)
  end

  def part2(input) do
    out =
      input
      |> parse
      |> perform_instructions(false)

    len = out |> Map.keys() |> length

    Enum.reduce(1..len, "", fn idx, acc ->
      acc <> hd(Map.fetch!(out, idx))
    end)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
