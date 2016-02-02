defmodule ExCss.Selectors.Specificity do
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN
  alias ExCss.Utils.Visitor, as: V

  defstruct a: 0, b: 0, c: 0
  @t __MODULE__

  def visit(stylesheet = %N.Stylesheet{}) do
    %{stylesheet | value: visit_node(stylesheet.value)}
  end

  defp visit_node(rule_list = %N.RuleList{}) do
    %{rule_list | rules: V.visit_nodes(&visit_node/1, rule_list.rules)}
  end

  defp visit_node(style_rule = %SN.StyleRule{}) do
    %{style_rule | selector: visit_selector(style_rule.selector)}
  end

  defp visit_node(node), do: node

  defp visit_selector(selector = %SN.Selector{}) do
    specificities = List.flatten(V.visit_nodes(&visit_selector/1, [selector.value]))
    %{selector | specificity: calculate(specificities)}
  end

  defp visit_selector(combinator = %SN.Combinator{}) do
    [
      visit_selector(combinator.left),
      visit_selector(combinator.right)
    ]
  end

  defp visit_selector(simple_selector = %SN.SimpleSelector{}) do
    [
      visit_selector(simple_selector.value),
      V.visit_nodes(&visit_selector/1, simple_selector.modifiers)
    ]
  end

  defp visit_selector(%SN.Hash{}), do: %@t{a: 1}
  defp visit_selector(%SN.Attribute{}), do: %@t{b: 1}
  defp visit_selector(%SN.Class{}), do: %@t{b: 1}
  defp visit_selector(%SN.Pseudo{type: :class}), do: %@t{b: 1}
  defp visit_selector(%SN.Pseudo{type: :element}), do: %@t{c: 1}
  defp visit_selector(%SN.Pseudo{type: :function}), do: %@t{} # not sure
  defp visit_selector(%SN.TypeSelector{}), do: %@t{c: 1}
  defp visit_selector(%SN.UniversalSelector{}), do: %@t{}
  defp visit_selector(negation = %SN.Negation{}), do: visit_selector(negation.value)

  defp calculate(specificities) do
    calculate(specificities, %@t{})
  end
  defp calculate([head | tail], acc) do
    calculate(tail, %{acc | a: acc.a + head.a, b: acc.b + head.b, c: acc.c + head.c})
  end
  defp calculate([], acc), do: acc.a * 100 + acc.b * 10 + acc.c
end
