# simple_selector_sequence
#   : [ type_selector | universal ]
#     [ HASH | class | attrib | pseudo | negation ]*
#   | [ HASH | class | attrib | pseudo | negation ]+
#   ;

defmodule ExCss.Selectors.Nodes.SimpleSelector do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct value: nil, modifiers: []

  def pretty_print(selector, indent) do
    PrettyPrint.pretty_out("Simple Selector:", indent)
    PrettyPrint.pretty_out(selector.value, indent + 1)
  end

  def parse(state) do
    state |> State.debug("-- CONSUMING A SIMPLE SELECTOR --")

    selector = %N.SimpleSelector{}

    State.debug(state, "currently: #{inspect state.token}")

    {state, value} = cond do # : [ type_selector | universal ]
      State.currently?(state, T.Id) -> N.TypeSelector.parse(state)
      State.currently?(state, T.Delim, "*") -> N.UniversalSelector.parse(state)
      true -> {state, nil}
    end

    State.debug(state, "value: #{inspect value} currently: #{inspect state.token}")
    State.debug(state, "consumg some modifiers")

    {state, modifiers} =
      state
      |> consume_some_modifiers

    if value do
      {state, %{selector | value: value, modifiers: modifiers}} # [ HASH | class | attrib | pseudo | negation ]*
    else
      if length(modifiers) > 0 do # | [ HASH | class | attrib | pseudo | negation ]+
        {state, %{selector | value: %N.UniversalSelector{}, modifiers: modifiers}}
      else
        {state, nil}
      end
    end
  end

  defp consume_some_modifiers(state, modifiers \\ []) do
    {state, modifier} = consume_modifier(state)

    if modifier do
      consume_some_modifiers(state, [modifier] ++ modifiers)
    else
      {state, Enum.reverse(modifiers)}
    end
  end

  defp consume_modifier(state) do
    cond do
      State.currently?(state, T.Hash) -> N.Hash.parse(state)
      State.currently?(state, T.Delim, ".") -> N.Class.parse(state)
      State.currently?(state, T.OpenSquare) -> N.Attribute.parse(state)
      State.currently?(state, T.Colon) -> N.Pseudo.parse(state)
      State.currently?(state, T.Function) && String.downcase(state.token.value) == "not" -> N.Negation.parse(state)
      true -> {state, nil}
    end
  end
end
