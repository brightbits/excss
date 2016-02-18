defmodule ExCss.Selectors.Finder do
  alias ExCss.Markup.Node, as: MN
  alias ExCss.Selectors.Nodes, as: SN

  def find(markup, selector) do
    filter(markup, [markup.id] ++ markup.descendant_ids, selector.value)
  end

  defp filter(markup, matching_ids, %SN.SimpleSelector{} = node) do
    print_ids(matching_ids, "Simple selector")

    matching_ids = filter(markup, matching_ids, node.value) # filter universal/type
    matching_ids = filter_list(markup, matching_ids, node.modifiers) # fitler modifiers
  end

  defp filter(markup, matching_ids, %SN.Combinator{type: :descendant, left: left, right: right}) do
    print_ids(matching_ids, "Descendant ")
    right_matching_ids = filter(markup, matching_ids, right)
    left_matching_ids = filter(markup, right_matching_ids, left)

    left_matching_ids
  end

  defp filter(markup, matching_ids, %SN.UniversalSelector{}) do
    print_ids(matching_ids, "Universal selector")
    matching_ids
  end

  defp filter(markup, matching_ids, %SN.TypeSelector{value: required_tag_name}) do
    print_ids(matching_ids, "Type selector (#{required_tag_name})")

    matching_ids = MN.visit(markup, [], fn (node, acc) ->
      IO.puts "NODE: #{node.tag_name} <> #{required_tag_name}"
      if MN.tag_name?(node, required_tag_name) do
        [node.id] ++ acc
      else
        acc
      end
    end)

    print_ids(matching_ids, "Remainining")
    Enum.reverse(matching_ids)
  end

  defp filter(markup, matching_ids, %SN.Class{value: required_class}) do
    print_ids(matching_ids, "Class modifier (#{required_class})")

    matching_ids = MN.visit(markup, [], fn (node, acc) ->
      IO.puts "NODE: #{MN.classes(node)} <> #{required_class}"
      if MN.class?(node, required_class) do
        [node.id] ++ acc
      else
        acc
      end
    end)

    print_ids(matching_ids, "Remainining")
    Enum.reverse(matching_ids)
  end

  defp filter(markup, matching_ids, %SN.Hash{value: required_id}) do
    print_ids(matching_ids, "Hash modifier (#{required_id})")

    matching_ids = MN.visit(markup, [], fn (node, acc) ->
      IO.puts "NODE: #{MN.attr(node, "id")} <> #{required_id}"
      if MN.attr(node, "id") == required_id do
        [node.id] ++ acc
      else
        acc
      end
    end)

    print_ids(matching_ids, "Remainining")
    Enum.reverse(matching_ids)
  end

  defp filter_list(markup, matching_ids, []), do: matching_ids
  defp filter_list(markup, matching_ids, [node | nodes]) do
    matching_ids = filter(markup, matching_ids, node)

    filter_list(markup, matching_ids, nodes)
  end

  defp print_ids(nil, text) do
    IO.puts "NO IDS #{text}"
  end

  defp print_ids(ids, text) do
    IO.puts "#{text}: #{Enum.join(ids, ", ")}"
  end
end
