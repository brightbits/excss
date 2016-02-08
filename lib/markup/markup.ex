defmodule ExCss.Markup do
  alias ExCss.Markup.Node, as: MN

  def new(html) do
    root_node = Floki.parse(html)
    {root_node, _} = apply_id_to_node(root_node, 0)
    root_node
  end

  def find_nodes(markup, tag_name) do
    Floki.find(markup, tag_name)
  end

  defp apply_id_to_node({_, _, children} = node, next_id) when is_tuple(node) do
    {new_children, new_next_id} = apply_ids_to_nodes(children, next_id + 1)

    node =
      node
      |> MN.set_id(next_id)
      |> MN.set_children(new_children)

    {node, new_next_id}
  end
  defp apply_id_to_node(node, next_id) when is_binary(node), do: {node, next_id}

  defp apply_ids_to_nodes(nodes, next_id), do: apply_ids_to_nodes(nodes, next_id, [])
  defp apply_ids_to_nodes([node | other_nodes], next_id, results) do
    {node, new_next_id} = apply_id_to_node(node, next_id)

    apply_ids_to_nodes(other_nodes, new_next_id, [node] ++ results)
  end
  defp apply_ids_to_nodes([], next_id, results) do
    {Enum.reverse(results), next_id}
  end
end
