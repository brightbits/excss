defmodule ExCss.Parser.Nodes.Stylesheet do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  defstruct value: nil

  def pretty_print(stylesheet), do: pretty_print(stylesheet, 0)
  def pretty_print(stylesheet, indent) do
    PrettyPrint.pretty_out("Stylesheet:", indent)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(stylesheet.value, indent + 2)
  end

  def parse(state) do
    parse_stylesheet(state)
  end

  defp parse_stylesheet(state) do
    # Create a new stylesheet.
    # Consume a list of rules from the stream of tokens, with the top-level flag set.
    # Assign the returned value to the stylesheet’s value.
    # Return the stylesheet.
    state |> State.debug("-- PARSING STYLESHEET --")

    {_, rule_list} = Nodes.RuleList.parse(state, true)

    {state, %Nodes.Stylesheet{value: rule_list}}
  end
end
