defmodule AdventOfCode.Year2022.Day11 do
  defmodule Test do
    defstruct [:divisible, true, false]

    def process(worry, %Test{divisible: by, true: t, false: f}) do
      {if rem(worry, by) == 0 do
         t
       else
         f
       end, worry}
    end
  end

  defmodule Operation do
    defstruct [:left, :operation, :right]

    def replace_old(arg, current) do
      case arg do
        :old -> current
        _ -> arg
      end
    end

    def process(%Operation{left: l, right: r, operation: op}, current) do
      {l, r} = {replace_old(l, current), replace_old(r, current)}

      case op do
        :mul -> l * r
        :add -> l + r
      end
    end

    @op_regex ~r/(?<left>(old|\d+)) (?<op>(\*|\+)) (?<right>(old|\d+))/

    defp parse_arg(arg) do
      case arg do
        "old" ->
          :old

        _ ->
          {n, _} = Integer.parse(arg)
          n
      end
    end

    def parse(op) do
      Regex.named_captures(@op_regex, op)
      |> Enum.reduce(%Operation{}, fn element, out ->
        case element do
          {"left", arg} -> %Operation{out | left: parse_arg(arg)}
          {"right", arg} -> %Operation{out | right: parse_arg(arg)}
          {"op", "*"} -> %Operation{out | operation: :mul}
          {"op", "+"} -> %Operation{out | operation: :add}
        end
      end)
    end
  end

  defmodule Monkey do
    defstruct id: 0, items: [], operation: %Operation{}, test: %Test{}, reduceWorry: true

    use GenServer

    @impl true
    def init(monkey) do
      {:ok, monkey}
    end

    @impl true
    def handle_call({:receive, new_items}, _from, monkey) do
      %Monkey{items: items} = monkey
      {:reply, :ok, %Monkey{monkey | items: items ++ new_items}}
    end

    @impl true
    def handle_call(:process, _from, monkey) do
      %Monkey{items: items, operation: op, test: test, reduceWorry: doReduce} = monkey

      targets =
        items
        |> Enum.map(fn worry ->
          Operation.process(op, worry)
          |> (&(if doReduce do
                  div(&1, 3)
                else
                  &1
                end)).()
          |> Test.process(test)
        end)
        |> Enum.reduce({%{}, 0}, fn {to, worry}, {map, count} ->
          {Map.merge(map, %{to => [worry]}, fn _, a, b -> a ++ b end), count + 1}
        end)

      {:reply, targets, %Monkey{monkey | items: []}}
    end

    def handle_call(:debug, _from, monkey) do
      %Monkey{items: items} = monkey
      {:reply, items, monkey}
    end
  end

  @monkey_regex ~r/Monkey (?<id>\d+):\n\s+Starting items: (?<items>(\d+(, )?)+)\n\s+Operation: new = (?<operation>((old|\d+|\*|\+) *)+)\n\s+Test: divisible by (?<divisible>\d+)\n\s+If true: throw to monkey (?<true>\d+)\n\s+If false: throw to monkey (?<false>\d+)/

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn monkey ->
      Regex.named_captures(@monkey_regex, monkey)
      |> Enum.reduce(%Monkey{}, fn element, m ->
        case element do
          {"id", id} ->
            {n, _} = Integer.parse(id)
            %Monkey{m | id: n}

          {"items", list} ->
            parsed =
              list
              |> String.split(", ")
              |> Enum.map(fn x ->
                {n, _} = Integer.parse(x)
                n
              end)

            %Monkey{m | items: parsed}

          {"operation", op} ->
            %Monkey{m | operation: Operation.parse(op)}

          {"true", target} ->
            {n, _} = Integer.parse(target)
            test = m.test
            %Monkey{m | test: %Test{test | true: n}}

          {"false", target} ->
            {n, _} = Integer.parse(target)
            test = m.test
            %Monkey{m | test: %Test{test | false: n}}

          {"divisible", target} ->
            {n, _} = Integer.parse(target)
            test = m.test
            %Monkey{m | test: %Test{test | divisible: n}}
        end
      end)
    end)
  end

  def initializeMonkeys(monks, reduceWorry) do
    monks
    |> Enum.reduce(%{}, fn monk, map ->
      {:ok, monkeyServer} = GenServer.start_link(Monkey, %Monkey{monk | reduceWorry: reduceWorry})
      %Monkey{id: id} = monk

      Map.put(map, id, monkeyServer)
    end)
  end

  # fuck this kid, I'm taking his jukebox.
  def murderMonkeys(monks) do
    monks
    |> Enum.reduce(fn {_, monk}, _ ->
      GenServer.stop(monk)
    end)
  end

  def run(input, rounds, reduceWorry \\ true) do
    parsed = input |> parse
    monks = parsed |> initializeMonkeys(reduceWorry)

    # 	  monks |>
    # 		  Enum.map(fn {id, monk} ->
    # 			  {id, GenServer.call(monk, :debug)} |> IO.inspect(charlists: :as_list)
    # 		  end)

    lcm =
      parsed
      |> Enum.map(fn %Monkey{test: %Test{divisible: by}} -> by end)
      |> IO.inspect()
      |> BasicMath.lcm()
      |> IO.inspect()

    counts =
      1..rounds
      |> Enum.reduce(%{}, fn _, table ->
        newTable =
          monks
          |> Enum.reduce(table, fn {id, monk}, totals ->
            {targets, count} = GenServer.call(monk, :process)
            # 				{id, targets} |> IO.inspect(charlists: :as_list)

            targets
            |> Enum.map(fn {target, items} ->
              receivingMonk = Map.fetch!(monks, target)

              GenServer.call(
                receivingMonk,
                {:receive, items |> Enum.map(&rem(&1, lcm))}
              )
            end)

            Map.merge(totals, %{id => count}, fn _k, c1, c2 -> c1 + c2 end)
          end)

        # 			"processing" |> IO.puts
        # 			round |> IO.inspect()
        #
        # 			monks |>
        # 			Enum.map(fn {id, monk} ->
        #       {id, GenServer.call(monk, :debug)} |> IO.inspect(charlists: :as_list)
        # 			end)

        newTable
      end)
      |> Enum.map(fn {_, sum} -> sum end)
      |> Enum.sort(&>=/2)
      |> Enum.take(2)
      |> Enum.reduce(0, fn x, acc ->
        case acc do
          0 -> x
          _ -> acc * x
        end
      end)

    murderMonkeys(monks)

    counts
  end

  def part1(input) do
    run(input, 20)
  end

  def part2(input) do
    run(input, 10_000, false)
  end

  # TODO: write generator
  # 	def generate(complexity) do
  #
  # 	end
end
