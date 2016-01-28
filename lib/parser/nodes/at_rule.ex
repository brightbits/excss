defmodule ExCss.Parser.Nodes.AtRule do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct name: nil, prelude: {}, block: nil

  def pretty_print(at_rule, indent) do
    PrettyPrint.pretty_out("At Rule:", indent)
    PrettyPrint.pretty_out("Name: #{at_rule.name}", indent + 1)

    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(at_rule.prelude, indent + 2)

    PrettyPrint.pretty_out("Block:", indent + 1)
    PrettyPrint.pretty_out(at_rule.block, indent + 2)
  end

  def parse(state) do
    consume_an_at_rule(state)
  end

  defp consume_an_at_rule(state) do
    state |> State.debug("-- CONSUMING AN AT RULE --")
    name = state.token.value
    state =
      state
      |> State.consume # step over AtToken
      |> State.consume_whitespace # if the current token is whitespace, step over it

    consume_an_at_rule(state, %N.AtRule{name: name, prelude: []})
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

    cond do
      State.currently?(state, [T.EndOfFile, T.Semicolon]) ->
        {State.consume(state), process_prelude(rule)}

      State.currently?(state, T.OpenCurly) ->
        {state, simple_block} = N.SimpleBlock.parse(state)
        {state, process_prelude(%{rule | block: simple_block})}
      true ->
        {state, component_value} = State.consume_component_value(state)
        consume_an_at_rule(state, %{rule | prelude: [component_value] ++ rule.prelude})
    end
  end

  defp process_prelude(rule) do
    prelude =
      rule.prelude
      |> Enum.reverse
      |> List.to_tuple

    %{rule | prelude: prelude}
  end
end
