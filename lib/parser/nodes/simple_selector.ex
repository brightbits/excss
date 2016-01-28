# simple_selector_sequence
#   : [ type_selector | universal ]
#     [ HASH | class | attrib | pseudo | negation ]*
#   | [ HASH | class | attrib | pseudo | negation ]+
#   ;

defmodule ExCss.Parser.Nodes.SimpleSelector do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil, modifiers: {}

  def pretty_print(selector, indent) do
    PrettyPrint.pretty_out("Simple Selector:", indent)
    PrettyPrint.pretty_out(selector.value, indent + 1)
  end

  def parse(state) do
    state |> State.debug("-- CONSUMING A SIMPLE SELECTOR --")

    selector = %Nodes.SimpleSelector{}

    State.debug(state, "currently: #{inspect state.token}")

    {state, value} = cond do # : [ type_selector | universal ]
      State.currently?(state, Tokens.Id) -> Nodes.TypeSelector.parse(state)
      State.currently?(state, Tokens.Delim, "*") -> Nodes.UniversalSelector.parse(state)
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
      if tuple_size(modifiers) > 0 do # | [ HASH | class | attrib | pseudo | negation ]+
        {state, %{selector | value: %Nodes.UniversalSelector{}, modifiers: modifiers}}
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
      modifiers =
        modifiers
        |> Enum.reverse
        |> List.to_tuple
      {state, modifiers}
    end
  end

  defp consume_modifier(state) do
    cond do
      State.currently?(state, Tokens.Hash) -> Nodes.Hash.parse(state)
      State.currently?(state, Tokens.Delim, ".") -> Nodes.Class.parse(state)
      State.currently?(state, Tokens.OpenSquare) -> Nodes.Attribute.parse(state)
      State.currently?(state, Tokens.Colon) -> Nodes.Pseudo.parse(state)
      State.currently?(state, Tokens.Function) && String.downcase(state.token.value) == "not" -> Nodes.Negation.parse(state)
      true -> {state, nil}
    end
  end
end
