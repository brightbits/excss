defmodule ExCss.Parser.Nodes.Negation do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil

  def pretty_print(hash, indent) do
    PrettyPrint.pretty_out("Negation:", indent)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(hash.value, indent + 2)
  end

  # negation
  #   : NOT S* negation_arg S* ')'
  #   ;
  #
  # negation_arg
  #   : type_selector | universal | HASH | class | attrib | pseudo
  #   ;
  def parse(state) do
    state |> State.debug("-- CONSUMING A NEGATION --")
    if State.currently?(state, Tokens.Function) && String.downcase(state.token.value) == "not" do
      {state, arg} =
        state
        |> State.consume # NOT
        |> State.consume_whitespace # S*
        |> consume_negation_arg # negation_arg

      if arg do
        {state, %Nodes.Negation{value: arg}}
      else
        {state, nil}
      end
    else
      {state, nil}
    end
  end

  defp consume_negation_arg(state) do
    {state, arg} = cond do
      State.currently?(state, Tokens.Id) -> Nodes.TypeSelector.parse(state)
      State.currently?(state, Tokens.Delim, "*") -> Nodes.UniversalSelector.parse(state)
      State.currently?(state, Tokens.Hash) -> Nodes.Hash.parse(state)
      State.currently?(state, Tokens.Delim, ".") -> Nodes.Class.parse(state)
      State.currently?(state, Tokens.OpenSquare) -> Nodes.Attribute.parse(state)
      State.currently?(state, Tokens.Colon) -> Nodes.Pseudo.parse(state)
      true -> {state, nil}
    end

    if arg do
      state = State.consume_whitespace(state) # S*

      if State.currently?(state, Tokens.CloseParenthesis) do
        {State.consume(state), arg} # )
      else
        {state, nil}
      end
    else
      {state, nil}
    end
  end
end
