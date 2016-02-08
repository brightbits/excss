defmodule ExCss.Selectors.Nodes.StyleRule do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN
  alias ExCss.Utils.Visitor, as: V

  defstruct selector: nil, declarations: {}

  def pretty_print(style_rule, indent) do
    PrettyPrint.pretty_out("Style Rule:", indent)
    PrettyPrint.pretty_out("Selector:", indent + 1)
    PrettyPrint.pretty_out(style_rule.selector, indent + 2)
    PrettyPrint.pretty_out("Declarations:", indent + 1)
    PrettyPrint.pretty_out(style_rule.declarations, indent + 2)
  end

  # defp apply_ids_to_markup_nodes(markup_nodes) when is_list(markup_nodes) do
  #   apply_ids_to_markup_nodes(markup_nodes, 0)
  # end
  #
  # defp apply_ids_to_markup_node(markup_node, next_id) when is_list(markup_nodes) do
  #   markup_node = Floki
  #   apply_ids_to_markup_nodes(markup_nodes, 0)
  # end
  #
  # def match(style_rule, markup_nodes) do
  #
  #   match_selector(style_rule.selector, )
  # end
  #
  # defp match_selector(%SN.SimpleSelector{}, markup_nodes, possible_ids) do
  #
  # end

  # look at SELECTOR
  #   its a simple_selector,
  #     return SELECTOR
  #   its a combinator,
  #     right is a simple_selector, return SELECTOR
  #     right is a combinator, find_deepest_simple_selector(SELECTOR.right)
  def find_deepest_simple_selector(%SN.SimpleSelector{} = selector), do: selector
  def find_deepest_simple_selector(%SN.Combinator{right: right}), do: find_deepest_simple_selector(right)

  def visit(stylesheet = %N.Stylesheet{}) do
    %{stylesheet | value: visit_node(stylesheet.value)}
  end

  defp visit_node(rule_list = %N.RuleList{}) do
    %{rule_list | rules: V.visit_nodes(&visit_node/1, rule_list.rules)}
  end

  defp visit_node(qualified_rule = %N.QualifiedRule{}) do
    state = State.new(qualified_rule.prelude)
    {_, selector} = ExCss.Selectors.Nodes.Selector.parse(state)

    state = State.new(qualified_rule.block.value)
    {_, declaration_list} = N.DeclarationList.parse(state)

    %ExCss.Selectors.Nodes.StyleRule{
      selector: selector,
      declarations: declaration_list
    }
  end

  defp visit_node(node), do: node
end
