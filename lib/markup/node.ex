defmodule ExCss.Markup.Node do
  defstruct tag_name: nil,
            attributes: [],
            children: [],
            id: nil,
            parent_id: nil,
            child_ids: [],
            descendant_ids: [],
            general_sibling_ids: [],
            adjacent_sibling_id: nil

  @t __MODULE__

  def new(node) when is_binary(node), do: node
  def new({tag_name, attributes, children}) do
    %@t{
      tag_name: tag_name,
      attributes: attributes,
      children: Enum.map(children, fn (child) -> new(child) end)
    }
  end

  def tag_name?(%@t{tag_name: tag_name}, required_tag_name) do
    String.downcase(tag_name) == String.downcase(required_tag_name)
  end

  def attr(%@t{attributes: attributes}, required_attr) do
    values =
      attributes
      |> Enum.filter(fn ({name, _}) -> String.downcase(name) == String.downcase(required_attr) end)
      |> Enum.map(fn ({_, value}) -> value end)

    if length(values) > 0 do
      hd(values)
    else
      ""
    end
  end

  def classes(%@t{} = node) do
    attr(node, "class")
    |> String.split(~r{\s+})
    |> Enum.reject(fn (value) -> String.length(value) == 0 end)
  end

  def class?(node, class) do
    Enum.any?(classes(node), fn (cls) -> String.downcase(cls) == class end)
  end

  def visit(%@t{} = node, acc, accfn) do
    acc = accfn.(node, acc)
    visit(node.children, acc, accfn)
  end
  def visit(nodes, acc, accfn) when is_list(nodes) do
    visit_nodes(nodes, acc, accfn)
  end
  def visit(node, acc, _) when is_binary(node), do: acc

  defp visit_nodes([node | nodes], acc, accfn) do
    acc = visit(node, acc, accfn)
    visit_nodes(nodes, acc, accfn)
  end
  defp visit_nodes([], acc, _), do: acc
end
