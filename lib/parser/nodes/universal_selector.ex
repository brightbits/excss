defmodule ExCss.Parser.Nodes.UniversalSelector do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct []

  def pretty_print(_, indent) do
    PrettyPrint.pretty_out("Universal Selector", indent)
  end

  def parse(state) do
    consume_a_universal_selector(state)
  end

  defp consume_a_universal_selector(state) do
    state |> State.debug("-- CONSUMING A UNIVERSAL SELECTOR --")

    if State.currently?(state, Tokens.Delim, "*") do
      {State.consume(state), %Nodes.UniversalSelector{}}
    else
      {state, nil}
    end
  end
end
