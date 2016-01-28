defmodule ExCss.Parser.Nodes.TypeSelector do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil

  def pretty_print(selector, indent) do
    PrettyPrint.pretty_out("Type Selector: #{selector.value}", indent)
  end

  def parse(state) do
    consume_a_type_selector(state)
  end

  defp consume_a_type_selector(state) do
    state |> State.debug("-- CONSUMING A TYPE SELECTOR --")

    if State.currently?(state, Tokens.Id) do
      {State.consume(state), %Nodes.TypeSelector{value: state.token.value}}
    else
      {state, nil}
    end
  end
end
