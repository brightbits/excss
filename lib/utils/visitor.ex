defmodule ExCss.Utils.Visitor do
  def visit_nodes(visit_fn, nodes), do: visit_nodes(visit_fn, nodes, [])
  defp visit_nodes(_, [], results), do: Enum.reverse(results)
  defp visit_nodes(visit_fn, [head | tail], results), do: visit_nodes(visit_fn, tail, [visit_fn.(head)] ++ results)
end
