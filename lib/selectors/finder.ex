defmodule ExCss.Selectors.Finder do
  alias ExCss.Markup, as: M
  alias ExCss.Markup.Node, as: MN
  alias ExCss.Selectors.Nodes, as: SN

  def find(markup, selector) do
    filter(markup, Set.union(MapSet.new([markup.id]), markup.descendant_ids), selector.value)
  end

  defp filter(markup, matching_ids, %SN.SimpleSelector{} = node) do
    IO.puts "SIMPLE!"
    print_ids(matching_ids, "Simple selector")
    IO.puts "UNIVERAL/TYPE!"
    matching_ids = filter(markup, matching_ids, node.value) # filter universal/type
    IO.puts "MODIFIERS!"
    matching_ids = filter_list(markup, matching_ids, node.modifiers) # fitler modifiers
  end

  defp filter(markup, matching_ids, %SN.Combinator{type: :descendant, left: left, right: right}) do
    print_ids(matching_ids, "Descendant ")
    right_matching_ids = filter(markup, matching_ids, right)

    print_ids(right_matching_ids, "Ids that match #{inspect right}")

    left_matching_ids = filter(markup, matching_ids, left)

    print_ids(left_matching_ids, "Ids that match #{inspect left}")

    matching_ids =
      MapSet.new(
        right_matching_ids
        |> Enum.filter(fn (right_id) ->
          left_matching_ids
          |> Enum.any?(fn (left_id) ->
            M.find_id(markup, left_id).descendant_ids
            |> Set.member?(right_id)
          end)
        end)
      )

    print_ids(matching_ids, "Final ids from descendant")
    matching_ids
    #
    # left_matching_ids.map lmid
    #   if rightmid is in lmnode.descendant_ids

    # |> Enum.filter(fn (left_id) ->
    #   ExCss.Markup.find_id(markup, left_id).descendant_ids
    #   |> Enum.any?(fn (id) ->
    # end)
  end

  defp filter(markup, matching_ids, %SN.UniversalSelector{}) do
    print_ids(matching_ids, "Universal selector")
    matching_ids
  end

  defp filter(markup, matching_ids, %SN.TypeSelector{value: required_tag_name}) do
    print_ids(matching_ids, "Type selector (#{required_tag_name})")

    matching_ids = MN.visit(markup, MapSet.new, fn (node, acc) ->
      if MN.tag_name?(node, required_tag_name) do
        Set.union(MapSet.new([node.id]), acc)
      else
        acc
      end
    end)

    print_ids(matching_ids, "Remainining (TS)")
    matching_ids
  end

  defp filter(markup, matching_ids, %SN.Class{value: required_class}) do
    print_ids(matching_ids, "Class modifier (#{required_class})")

    matching_ids = filter_nodes(markup, matching_ids, fn (node) ->
      MN.class?(node, required_class)
    end)

    print_ids(matching_ids, "Remainining")
    matching_ids
  end

  defp filter(markup, matching_ids, %SN.Hash{value: required_id}) do
    print_ids(matching_ids, "Hash modifier (#{required_id})")

    matching_ids = filter_nodes(markup, matching_ids, fn (node) ->
      MN.attr(node, "id") == required_id
    end)

    print_ids(matching_ids, "Remainining")
    matching_ids
  end

  defp filter_list(markup, matching_ids, []), do: matching_ids
  defp filter_list(markup, matching_ids, [node | nodes]) do
    IO.puts "filter_list: #{inspect node} / #{inspect nodes}"
    matching_ids = filter(markup, matching_ids, node)

    filter_list(markup, matching_ids, nodes)
  end

  defp filter_nodes(markup, matching_ids, pred) do
    MN.visit(markup, MapSet.new, fn (node, acc) ->
      if Set.member?(matching_ids, node.id) && pred.(node) do
        Set.put(acc, node.id)
      else
        acc
      end
    end)
  end

  defp print_ids(nil, text) do
    IO.puts "NO IDS #{text}"
  end

  defp print_ids(ids, text) do
    IO.puts "#{text}: #{Enum.join(Set.to_list(ids), ", ")}"
  end
end
