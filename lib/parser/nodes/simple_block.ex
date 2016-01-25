defmodule ExCss.Parser.Nodes.SimpleBlock do
  import ExCss.Utils.PrettyPrint
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Utils.Log
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.Token
  defstruct associated_token: nil, value: []

  def pretty_print(simple_block, indent) do
    pretty_out("Simple Block #{Token.to_pretty(simple_block.associated_token)}:", indent)

    for token <- simple_block.value do
      pretty_out(Token.to_pretty(token), indent + 1)
    end
  end

  def parse(state) do
    consume_a_simple_block(state)
  end

  defp consume_a_simple_block(state) do
    Log.debug "-- CONSUMING A SIMPLE BLOCK --"
    # The ending token is the mirror variant of the current input token. (E.g. if it was called with <[-token>, the ending token is <]-token>.)
    #
    # Create a simple block with its associated token set to the current input token and with a value with is initially an empty list.
    ending_token_type = State.token_mirror(state)
    consume_a_simple_block(state, ending_token_type, %ExCss.Parser.Nodes.SimpleBlock{associated_token: state.token, value: []})
  end
  defp consume_a_simple_block(state, ending_token_type, simple_block) do
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # ending token
    # Return the block.
    # anything else
    # Reconsume the current input token. Consume a component value and append it to the value of the block.

    state = state |> State.consume

    if State.currently?(state, [Tokens.EndOfFile, ending_token_type]) do
      {state, simple_block}
    else
      {state, component_value} = state |> State.reconsume |> ExCss.Parser.consume_a_component_value

      consume_a_simple_block(state, ending_token_type, %{simple_block | value: simple_block.value ++ [component_value]})
    end
  end
end
