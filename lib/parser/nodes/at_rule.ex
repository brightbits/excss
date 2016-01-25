defmodule ExCss.Parser.Nodes.AtRule do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Utils.Log
  alias ExCss.Parser
  alias ExCss.Parser.Nodes
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  defstruct name: nil, prelude: [], block: nil

  def pretty_print(_, indent) do
    PrettyPrint.pretty_out("At rule", indent)
  end

  def parse(state) do
    consume_an_at_rule(state)
  end

  defp consume_an_at_rule(state) do
    Log.debug "-- CONSUMING AN AT RULE --"
    consume_an_at_rule(state, %ExCss.Parser.Nodes.AtRule{name: state.token.value})
  end
  defp consume_an_at_rule(state, rule) do
    # Create a new at-rule with its name set to the value of the current input token,
    # its prelude initially set to an empty list, and its value initially set to nothing.
    #
    # Repeatedly consume the next input token:
    #
    # <semicolon-token>
    # <EOF-token>
    # Return the at-rule.
    # <{-token>
    # Consume a simple block and assign it to the at-rule’s block. Return the at-rule.
    # simple block with an associated token of <{-token>
    # Assign the block to the at-rule’s block. Return the at-rule.
    # anything else
    # Reconsume the current input token. Consume a component value. Append the returned value to the at-rule’s prelude.
    state = state |> State.consume

    if State.currently?(state, [Tokens.EndOfFile, Tokens.Semicolon]) do
      {state, rule}
    else
      if state |> State.currently?(Tokens.OpenCurly) do
        {state, simple_block} = Nodes.SimpleBlock.parse(state)
        rule = %{rule | block: simple_block}
        {state, rule}
      else
        state = state |> State.reconsume
        {state, component_value} = state |> Parser.consume_a_component_value
        rule = %{rule | prelude: rule.prelude ++ [component_value]}

        consume_an_at_rule(state, rule)
      end
    end
  end
end
