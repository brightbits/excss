defmodule ExCss.Parser.Nodes.QualifiedRule do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Utils.Log
  alias ExCss.Parser
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.Token

  defstruct prelude: [], block: nil

  def pretty_print(qualified_rule, indent) do
    PrettyPrint.pretty_out("Qualified Rule:", indent)
    PrettyPrint.pretty_out("Prelude:", indent + 1)

    for token <- qualified_rule.prelude do
      PrettyPrint.pretty_out(Token.to_pretty(token), indent + 2)
    end

    state = ExCss.Parser.State.new(qualified_rule.block.value)
    {_, declaration} = ExCss.Parser.consume_a_list_of_declarations(state)
    IO.puts "block result: #{inspect declaration}"
    #
    #
    # ExCss.Parser.SimpleBlock.pretty_print(qualified_rule.block, indent + 1)
  end

  def parse(state) do
    consume_a_qualified_rule(state)
  end

  defp consume_a_qualified_rule(state) do
    Log.debug "-- CONSUMING A QUALIFIED RULE --"
    consume_a_qualified_rule(state, %Nodes.QualifiedRule{})
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

    state = state |> State.consume
    if state |> State.currently?(Tokens.EndOfFile) do
      {state, nil}
    else
      cond do
        State.currently_simple_block?(state) ->
          rule = %{rule | block: state.token}

          {state, rule}
        state |> State.currently?(Tokens.OpenCurly) ->
          {state, simple_block} = Nodes.SimpleBlock.parse(state)
          rule = %{rule | block: simple_block}
          
          {state, rule}
        true ->
          {state, component_value} = state |> State.reconsume |> Parser.consume_a_component_value
          rule = %{rule | prelude: rule.prelude ++ [component_value]}

          consume_a_qualified_rule(state, rule)
      end
    end
  end
end
