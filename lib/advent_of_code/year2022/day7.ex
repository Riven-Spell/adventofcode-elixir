defmodule AdventOfCode.Year2022.Day7 do
  # Really add it all up, please.
  defp trueCalculateSize(object) do
    object
    |> Enum.reduce({object, 0}, fn
      {key, val}, {fs, total} when is_map(val) ->
        {modified, size} = calculateSize(val)
        {Map.put(fs, key, modified), total + size}

      # file
      {_, val}, {fs, total} ->
        {fs, total + val}
    end)
    |> (fn {fs, total} -> {Map.put(fs, :cachedSize, total), total} end).()
  end

  # First, attempt to grab :cachedSize.
  def calculateSize(object) do
    case Map.fetch(object, :cachedSize) do
      {:ok, size} -> {object, size}
      :error -> trueCalculateSize(object)
    end
  end

  # merge a new directory structure into the existing one, recursively
  def mergeTrees(a, b) do
    Map.merge(a, b, fn
      _, m1, m2 when is_map(m1) and is_map(m2) ->
        mergeTrees(m1, m2)

      # this should never happen
      _, _, _ ->
        raise "mergeTrees shouldn't have overlapping files."
    end)
  end

  # create the path as a real tree/directory structure
  def createPath(path, size) do
    path
    |> String.split("/", trim: true)
    |> Enum.reverse()
    |> Enum.reduce(size, fn segment, acc ->
      %{segment => acc}
    end)
  end

  # append a new segment to a path
  def appendPath(path, segment) do
    case path do
      "" -> segment
      _ -> path <> "/" <> segment
    end
  end

  # pop an element off the path
  def popPath(path) do
    case path do
      "" ->
        path

      path ->
        path
        |> String.split("/", trim: true)
        |> Enum.reverse()
        |> tl
        |> Enum.reverse()
        |> Enum.join("/")
    end
  end

  # construct the filesystem
  def buildFS(input) do
    {_, fs} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce({"", %{}}, fn line, {cwd, fs} ->
        case line do
          "$ ls" ->
            {cwd, fs}

          "$ cd .." ->
            {popPath(cwd), fs}

          "$ cd /" ->
            {"", fs}

          "$ cd " <> segment ->
            {appendPath(cwd, segment), fs}

          "dir " <> _ ->
            {cwd, fs}

          file ->
            [size, name] = String.split(file, " ", trim: true)
            {size, _} = Integer.parse(size)

            {cwd, mergeTrees(fs, createPath(Path.join(cwd, name), size))}
        end
      end)

    fs
  end

  # Sum all items below 100k size
  def part1_sum(fs) do
    fs
    |> Enum.reduce(0, fn
      {:cachedSize, size}, sum -> # Append the cached size if small enough
        if size <= 100_000 do
          sum + size
        else
          sum
        end

      {_, dir}, sum when is_map(dir) -> # Append any found sizes
        sum + part1_sum(dir)

      {_, _}, sum -> # Do not handle files.
        sum
    end)
  end

  def part1(input) do
    {fs, _} = input |> buildFS() |> calculateSize()

    part1_sum(fs)
  end

  # Sort a list of all folder sizes
  def part2_getSizes(fs) do
    fs
    |> Enum.reduce([], fn
      {:cachedSize, n}, acc -> acc ++ [n] # Add cached size to list
      {_, dir}, acc when is_map(dir) -> acc ++ part2_getSizes(dir) # Add all found sizes
      {_, _}, acc -> acc # Ignore files
    end)
    |> Enum.sort(&>=/2)
  end

  # Recursively find the best item
  def part2_findBest([item | tail], freeSpace) do
	  if item + freeSpace < 30000000 do
		  false
	  else
	    case part2_findBest(tail, freeSpace) do
		    false -> item
		    newAnswer -> newAnswer
	    end
	  end
  end

  def part2(input) do
    {fs, totalSize} = input |> buildFS() |> calculateSize()

    part2_getSizes(fs) |> part2_findBest(70000000 - totalSize)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
