defmodule ExCss.Markup do
  alias ExCss.Markup.Node, as: MN

  def new(html) do
    Floki.parse(html)
    |> MN.new
    |> apply_id_to_node
    |> apply_parent_id_to_node
    |> apply_descendant_ids_to_node
    |> apply_child_ids_to_node
    |> apply_sibling_ids_to_node
  end

  def find_id(markup, id) do
    nodes = MN.visit(markup, [],
      fn (node, acc) ->
        if node.id == id do
          [node]
        else
          acc
        end
      end
    )

    List.first(nodes)
  end

  def find_nodes(markup, tag_name) do
    nodes = MN.visit(markup, [],
      fn (node, acc) ->
        if MN.tag_name?(node, tag_name) do
          [node] ++ acc
        else
          acc
        end
      end
    )

    Enum.reverse(nodes)
  end

  defp apply_sibling_ids_to_node(node), do: apply_sibling_ids_to_node(node, nil)
  defp apply_sibling_ids_to_node(%MN{} = node, parent_node) do
    children = Enum.map(node.children, fn (child) ->
      apply_sibling_ids_to_node(child, node)
    end)

    node = if parent_node do
      sibling_ids =
        parent_node.children
        |> Enum.map(fn
          (%MN{id: id}) -> id
          (_) -> nil
        end)
        |> Enum.reject(fn (id) -> id == nil || id == node.id end)

      adjacent_sibling_ids =
        sibling_ids
        |> Enum.filter(fn (id) -> id > node.id end)

      %{
        node |
        general_sibling_ids: MapSet.new(sibling_ids),
        adjacent_sibling_id: List.first(adjacent_sibling_ids)
      }
    else
      node
    end

    %{node | children: children}
  end
  defp apply_sibling_ids_to_node(node, _) when is_binary(node), do: node

  defp apply_child_ids_to_node(%MN{} = node) do
    children = Enum.map(node.children, fn (child) ->
      apply_child_ids_to_node(child)
    end)

    child_ids =
      children
      |> Enum.map(fn
        (%MN{id: id}) -> id
        (_) -> nil
      end)
      |> Enum.reject(fn (id) -> id == nil end)

    %{node | child_ids: MapSet.new(child_ids), children: children}
  end
  defp apply_child_ids_to_node(node) when is_binary(node), do: node

  defp apply_descendant_ids_to_node(%MN{} = node) do
    children = Enum.map(node.children, fn (child) ->
      apply_descendant_ids_to_node(child)
    end)

    descendant_ids =
      children
      |> Enum.flat_map(fn
        (%MN{id: id, descendant_ids: descendant_ids}) -> [id] ++ Set.to_list(descendant_ids)
        (_) -> []
      end)
      |> Enum.reject(fn (id) -> id == nil end)

    %{node | descendant_ids: MapSet.new(descendant_ids), children: children}
  end
  defp apply_descendant_ids_to_node(node) when is_binary(node), do: node

  defp apply_parent_id_to_node(node), do: apply_parent_id_to_node(node, nil)
  defp apply_parent_id_to_node(%MN{} = node, parent_id) do
    %{node | parent_id: parent_id, children: Enum.map(node.children, fn (child) ->
      apply_parent_id_to_node(child, node.id)
    end)}
  end
  defp apply_parent_id_to_node(node, _) when is_binary(node), do: node

  defp apply_id_to_node(node) do
    {node, _} = apply_id_to_node(node, 0)
    node
  end
  defp apply_id_to_node(%MN{} = node, next_id) do
    {new_children, new_next_id} = apply_ids_to_nodes(node.children, next_id + 1, [])

    node = %{node | id: next_id, children: new_children}

    {node, new_next_id}
  end
  defp apply_id_to_node(node, next_id) when is_binary(node), do: {node, next_id}

  defp apply_ids_to_nodes([node | other_nodes], next_id, results) do
    {node, new_next_id} = apply_id_to_node(node, next_id)

    apply_ids_to_nodes(other_nodes, new_next_id, [node] ++ results)
  end
  defp apply_ids_to_nodes([], next_id, results) do
    {Enum.reverse(results), next_id}
  end
end
