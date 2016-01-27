defmodule ExCss.Parser.Nodes.Hash do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil

  def pretty_print(hash, indent) do
    PrettyPrint.pretty_out("Hash:", indent)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(hash.value, indent + 2)
  end

  def parse(state) do
    state |> State.debug("-- CONSUMING A HASH --")
    if State.currently?(state, Tokens.Hash) do
      {State.consume(state), %Nodes.Hash{value: state.token.value}}
    else
      {state, nil}
    end
  end
end
