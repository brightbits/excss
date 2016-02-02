defmodule ExCss.Selectors.Nodes.Class do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct [:value]

  def pretty_print(class, indent) do
    PrettyPrint.pretty_out("Class: #{class.value}", indent)
  end

  def parse(state) do
    state = state |> State.consume

    if State.currently?(state, T.Id) do
      {State.consume(state), %N.Class{value: state.token.value}}
    else
      {state, nil}
    end
  end
end
