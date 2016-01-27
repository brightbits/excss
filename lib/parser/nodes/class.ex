defmodule ExCss.Parser.Nodes.Class do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil

  def pretty_print(class, indent) do
    PrettyPrint.pretty_out("Class: #{class.value}", indent)
  end

  def parse(state) do
    state = state |> State.consume

    if State.currently?(state, Tokens.Id) do
      {State.consume(state), %Nodes.Class{value: state.token.value}}
    else
      {state, nil}
    end
  end
end
