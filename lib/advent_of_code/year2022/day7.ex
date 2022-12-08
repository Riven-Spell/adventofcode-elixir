defmodule AdventOfCode.Year2022.Day7 do
  # reduce the remaining sumstack down and apply it to sums
  defp finalizeTraversal({_, sumStack, sums}) do
    case sumStack do
      # No-op sanity check
      [] -> sums
      # Add top level directory to sums
      [a] -> [a] ++ sums
      # recurse, yanking off & combining the sum
      [a, b | tail] -> finalizeTraversal({nil, [a + b] ++ tail, [a] ++ sums})
    end
  end

  # using stacks, discover the full list of sums (since dirname is no longer needed)
  def buildSizes_flat(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], [0], []}, fn line, {cwd, sumStack, sums} ->
      case line do
        # no-op
        "$ ls" ->
          {cwd, sumStack, sums}

        # no-op
        "$ cd /" ->
          {cwd, sumStack, sums}

        # drop the top sum & directory, combining into parent directory sum
        "$ cd .." ->
          [a, b | tail] = sumStack
          {tl(cwd), [a + b] ++ tail, [a] ++ sums}

        # add a new directory to the stack
        "$ cd " <> segment ->
          {[segment] ++ cwd, [0] ++ sumStack, sums}

        # no-op; just ls outputting directory, effectively garbage
        "dir" <> _ ->
          {cwd, sumStack, sums}

        # get file size & add it to current sum
        file ->
          [size, name] = String.split(file, " ", trim: true)
          {size, _} = Integer.parse(size)

          [sum | tail] = sumStack
          {cwd, [sum + size] ++ tail, sums}
      end
    end)
    # drop any remaining traversal items
    |> finalizeTraversal()
  end

  # Find sum of sub-100k numbers
  def part1(input) do
    input
    |> buildSizes_flat()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  # Find the smallest folder that would satisfy required storage
  def part2(input) do
    [fullSize | directories] =
      input
      |> buildSizes_flat()
      |> Enum.sort(&>=/2)

    remaining = 70_000_000 - fullSize
    needed = 30_000_000 - remaining

    directories
    |> Enum.reverse()
    |> Enum.find(&(&1 >= needed))
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
