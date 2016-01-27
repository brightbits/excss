defmodule ExCss.Parser.Nodes.SimpleBlock do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  defstruct associated_token: nil, value: []

  def pretty_print(simple_block, indent) do
    PrettyPrint.pretty_out("Simple Block:", indent)
    PrettyPrint.pretty_out("Associated token:", indent + 1)
    PrettyPrint.pretty_out(simple_block.associated_token, indent + 2)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(simple_block.value, indent + 2)
  end

  def parse(state) do
    consume_a_simple_block(state)
  end

  defp consume_a_simple_block(state) do
    state |> State.debug("-- CONSUMING A SIMPLE BLOCK --")
    # The ending token is the mirror variant of the current input token. (E.g. if it was called with <[-token>, the ending token is <]-token>.)
    #
    # Create a simple block with its associated token set to the current input token and with a value with is initially an empty list.
    ending_token_type = State.token_mirror(state)
    associated_token = state.token

    state =
      state
      |> State.consume # step over opening of block
      |> State.consume_whitespace # if current token is whitespace skip it

    consume_a_simple_block(
      state,
      ending_token_type,
      %ExCss.Parser.Nodes.SimpleBlock{
        associated_token: associated_token,
        value: []
      }
    )
  end
  defp consume_a_simple_block(state, ending_token_type, simple_block) do
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # ending token
    # Return the block.
    # anything else
    # Reconsume the current input token. Consume a component value and append it to the value of the block.

    if State.currently?(state, [Tokens.EndOfFile, ending_token_type]) do
      {State.consume(state), simple_block}
    else
      {state, component_value} =
        state
        |> State.consume_component_value

      consume_a_simple_block(state, ending_token_type, %{simple_block | value: simple_block.value ++ [component_value]})
    end
  end
end
