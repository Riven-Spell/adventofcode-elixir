defmodule AdventOfCode do
  @moduledoc """
  AdventOfCode defines a project structure & traverses it to help manage execution of days.
  """

  defp listModules do
    {:ok, modules} = :application.get_key(:advent_of_code, :modules)

    modules
  end

  defp getSolutionDate(solution) do
    Atom.to_string(solution)
    |> (&Regex.scan(~r/(?<=(?:Year)|(?:Day))\d+/, &1)).()
    |> List.flatten()
    |> Enum.map(fn x ->
      {n, _} = Integer.parse(x)
      n
    end)
    |> List.to_tuple()
  end

  def getDay(target) do
    {year, day} = target

    String.to_existing_atom("Elixir.AdventOfCode.Year#{year}.Day#{day}")
  end

  def listDays do
    listModules()
    |> Enum.filter(fn x ->
      Atom.to_string(x)
      |> (&Regex.match?(~r/^Elixir\.AdventOfCode\.Year\d{4}\.Day\d{1,2}$/, &1)).()
    end)
  end

  def currentDay do
    listDays()
    |> Enum.map(&getSolutionDate(&1))
    # Default to day 0 of 2015, since that doesn't exist and AoC started in 2015.
    |> Enum.reduce({2015, 0}, fn x, acc ->
      {accYear, accDay} = acc
      {year, day} = x

      if year * 10 + day > accYear * 10 + accDay do
        x
      else
        acc
      end
    end)
  end
end
