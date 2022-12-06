defmodule Mix.Tasks.Input do
  @moduledoc "Grab & cache Advent of Code inputs by day & year"
  use Mix.Task

  defmodule Arguments do
    defstruct [:day, :year, :mode, :complexity, :error, echo: true]

    def parse(args) do
      {out, argv, _} =
        OptionParser.parse(args,
          switches: [day: :integer, year: :integer, echo: :boolean, complexity: :integer]
        )

      Enum.reduce(out, %Arguments{}, fn x, acc ->
        case x do
          {:day, day} -> %{acc | day: day}
          {:year, year} -> %{acc | year: year}
          {:mode, mode} -> %{acc | mode: mode}
          {:echo, echo} -> %{acc | echo: echo}
          {:complexity, level} -> %{acc | complexity: level}
        end
      end)
      |> handleArgv(argv)
      |> validateArgs
    end

    def getTargetDate(%Arguments{day: day, year: year}) do
      if day == nil || year == nil do
        AdventOfCode.currentDay()
      else
        {year, day}
      end
    end

    defp handleArgv(args, argv) do
      len = length(argv)

      if len != 1 do
        {:error, "valid download modes are \"download\", \"generate\" and \"print\"."}
      else
        {:ok, %{args | mode: String.downcase(hd(argv))}}
      end
    end

    defp validateArgs(toValidate) do
      case toValidate do
        {:ok, args} -> checkMode(args)
        {:error, _} -> toValidate
      end
    end

    @validModes ["download", "generate", "print"]

    defp checkMode(args) do
      if Enum.member?(@validModes, Map.fetch!(args, :mode)) do
        {:ok, args}
      else
        {:error, "valid download modes are \"download\", \"generate\" and \"print\"."}
      end
    end
  end

  @shortdoc "Grab & cache Advent of Code inputs by day & year"
  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {:ok, arguments} = args |> Arguments.parse() |> IO.inspect()
    targetDate = Arguments.getTargetDate(arguments)

    input =
      case arguments.mode do
        "download" ->
          targetDate |> InputCache.downloadInput()

        "generate" ->
          targetDate |> InputCache.generateInput(arguments.complexity)

        "print" ->
          targetDate |> InputCache.getInput()
      end

    if arguments.mode != "print" do
      targetDate |> InputCache.storeInput(input)
    end

    if arguments.echo do
      input |> IO.puts()
    end
  end
end
