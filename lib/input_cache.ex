defmodule InputCache do
  @moduledoc """
  InputCache pulls, generates, and stores inputs.

  `target` fields are expected to be `{year, day}` tuples.
  """
  def generateInput({year, day}, complexity) do
    AdventOfCode.getDay({year, day}).generate(complexity)
  end

  def downloadInput({year, day}) do
    url = "https://www.adventofcode.com/#{year}/day/#{day}/input"
    # TODO; use config
    session = System.get_env("AOC_SESSION")
    req = Req.new(url: url, headers: [{"Cookie", "session=#{session}"}])
    Req.get!(req).body
  end

  defp getInputPath({year, day}) do
    ip =
      System.user_home!()
      |> Path.join(".aocf/#{year}/#{day}.txt")

    ip |> Path.dirname() |> File.mkdir_p!()

    ip
  end

  def storeInput({year, day}, input) do
    {:ok, file} = File.open(getInputPath({year, day}), [:write])

    file |> :file.position(:bof) |> :file.truncate()
    file |> IO.binwrite(input)
  end

  def getInput({year, day}) do
    File.read(getInputPath({year, day}))
  end

  @doc """
  getInputOrCreate attempts a standard getInput, and if that fails, `:download`s or `:generate`s an input and stores it.
  """
  def getInputOrCreate(targetDay, mode \\ :download, complexity \\ 10) do
    case getInput(targetDay) do
      {:ok, data} ->
        {:ok, data}

      _ ->
        input =
          case mode do
            :download ->
              downloadInput(targetDay)

            :generate ->
              generateInput(targetDay, complexity)
          end

        storeInput(targetDay, input)
        {:ok, input}
    end
  end
end
