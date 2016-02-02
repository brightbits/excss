defmodule ExCss.Parser.Nodes.QualifiedRule do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct prelude: [], block: nil

  def pretty_print(qualified_rule, indent) do
    PrettyPrint.pretty_out("Qualified Rule:", indent)
    PrettyPrint.pretty_out("Prelude:", indent + 1)

    state = State.new(qualified_rule.prelude)
    {_, selector} = N.Selector.parse(state)
    PrettyPrint.pretty_out(selector, indent + 2)

    state = State.new(qualified_rule.block.value)
    {_, declaration_list} = N.DeclarationList.parse(state)
    PrettyPrint.pretty_out(declaration_list, indent + 1)
  end

  def parse(state) do
    consume_a_qualified_rule(state)
  end

  defp consume_a_qualified_rule(state) do
    state |> State.debug("-- CONSUMING A QUALIFIED RULE --")
    state = State.consume_whitespace(state)

    {state, rule} = consume_a_qualified_rule(state, %N.QualifiedRule{})

    if rule do
      {state, %{rule | prelude: Enum.reverse(rule.prelude)}}
    else
      {state, rule}
    end
  end
  defp consume_a_qualified_rule(state, rule) do
    # Create a new qualified rule with its prelude initially set to an empty list, and its value initially set to nothing.
    #
    # Repeatedly consume the next input token:
    #
    # <EOF-token>
    # This is a parse error. Return nothing.
    # <{-token>
    # Consume a simple block and assign it to the qualified rule’s block. Return the qualified rule.
    # simple block with an associated token of <{-token>
    # Assign the block to the qualified rule’s block. Return the qualified rule.
    # anything else
    # Reconsume the current input token. Consume a component value. Append the returned value to the qualified rule’s prelude.

    if state |> State.currently?(T.EndOfFile) do
      {state, nil}
    else
      cond do
        State.currently_simple_block?(state) ->
          {state, %{rule | block: state.token}}
        state |> State.currently?(T.OpenCurly) ->
          {state, simple_block} = N.SimpleBlock.parse(state)
          {state, %{rule | block: simple_block}}
        true ->
          {state, component_value} = State.consume_component_value(state)

          consume_a_qualified_rule(state, %{rule | prelude: [component_value] ++ rule.prelude})
      end
    end
  end
end
