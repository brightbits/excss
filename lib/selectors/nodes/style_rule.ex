defmodule ExCss.Selectors.Nodes.StyleRule do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN
  alias ExCss.Utils.Visitor, as: V

  defstruct selector_list: nil, declarations: {}

  def pretty_print(style_rule, indent) do
    PrettyPrint.pretty_out("Style Rule:", indent)
    PrettyPrint.pretty_out("Selector:", indent + 1)
    PrettyPrint.pretty_out(style_rule.selector, indent + 2)
    PrettyPrint.pretty_out("Declarations:", indent + 1)
    PrettyPrint.pretty_out(style_rule.declarations, indent + 2)
  end

  def visit(stylesheet = %N.Stylesheet{}) do
    %{stylesheet | value: visit_node(stylesheet.value)}
  end

  defp visit_node(rule_list = %N.RuleList{}) do
    %{rule_list | rules: V.visit_nodes(&visit_node/1, rule_list.rules)}
  end

  defp visit_node(qualified_rule = %N.QualifiedRule{}) do
    state = State.new(qualified_rule.prelude)
    {_, selector_list} = ExCss.Selectors.Nodes.SelectorList.parse(state)

    state = State.new(qualified_rule.block.value)
    {_, declaration_list} = N.DeclarationList.parse(state)

    %ExCss.Selectors.Nodes.StyleRule{
      selector_list: selector_list,
      declarations: declaration_list
    }
  end

  defp visit_node(node), do: node
end
