defmodule AdventOfCode.Year2022.Day10 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn command ->
      case hd(command) do
        "noop" ->
          {:noop, 0}

        "addx" ->
          ["addx", num] = command
          {n, _} = Integer.parse(num)
          {:addx, n}
      end
    end)
  end

  def execute({opcode, arg}, clock \\ 0, acc \\ 0) do
    case opcode do
      :noop -> {clock + 1, acc}
      :addx -> {clock + 2, acc + arg}
    end
  end

  def part1(input) do
    cpuStates =
      input
      |> parse
      |> Enum.reduce({1, 1, %{}}, fn op, state ->
        {clock, acc, states} = state

        {nClock, nAcc} = execute(op, clock, acc)

        {nClock, nAcc,
         Enum.reduce(clock..nClock, states, fn cl, st ->
           Map.put(st, cl, acc)
         end)}
      end)
      |> (fn {_, _, states} -> states end).()

    20..220//40
    |> Enum.reduce(0, fn x, sum ->
      new = x * Map.fetch!(cpuStates, x)
      sum + new
    end)
  end

  def part2(input) do
    cpuStates =
      input
      |> parse
      |> Enum.reduce({1, 1, %{}}, fn op, state ->
        {clock, acc, states} = state

        {nClock, nAcc} = execute(op, clock, acc)

        {nClock, nAcc,
         Enum.reduce(clock..nClock, states, fn cl, st ->
           Map.put(st, cl, acc)
         end)}
      end)
      |> (fn {_, _, states} -> states end).()

    40..240//40
    |> Enum.reduce("", fn rend, screen ->
      rstart = rend - 40 + 1

      rstart..rend
      |> Enum.reduce("", fn x, line ->
        normalized = Map.fetch!(cpuStates, x)
        spriteRange = (normalized - 1)..(normalized + 1)

        line <>
          if Enum.member?(spriteRange, x - rstart) do
            "#"
          else
            "."
          end
      end)
      |> IO.puts()
    end)

    nil
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
