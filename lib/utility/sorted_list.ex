defmodule SortedList do
  # Defaults descending
  defstruct data: [], order: &>=/2, fixedLength: false

  @moduledoc """
  Implements a priority queue. `order` can be `ascending` or `descending`, and `fixedLength` is either false or a target length.
  """

  @doc """
  Descending function for insert order
  """
  def descending do
    &>=/2
  end

  @doc """
  Ascending function for insert order
  """
  def ascending do
    &<=/2
  end

  def insert(%SortedList{data: queue, order: order, fixedLength: fLen}, x) do
    {queue, order, fLen}

    {newQueue, item} =
      queue
      |> Enum.map_reduce(:noop, fn item, acc ->
        if acc == :noop do
          if !order.(x, item) do
            {item, :noop}
          else
            {x, item}
          end
        else
          # Swap last item for current item, pushing down
          {acc, item}
        end
      end)

    %SortedList{
      data:
        if newQueue == [] do
          [x]
        else
          newQueue
        end,
      fixedLength: fLen,
      order: order
    }
    |> handleRemainder(item)
    |> handleFixedLength
  end

  defp handleRemainder(queue, remainder) do
    %SortedList{data: list} = queue

    if remainder != :noop do
      %SortedList{queue | data: list ++ [remainder]}
    else
      queue
    end
  end

  defp handleFixedLength(queue) do
    %SortedList{data: list, fixedLength: fLen} = queue

    if fLen != false do
      %SortedList{queue | data: Enum.take(list, fLen)}
    else
      queue
    end
  end

  @doc """
  Extract the list from within.
  """
  def getList(%SortedList{data: data}) do
    data
  end
end
