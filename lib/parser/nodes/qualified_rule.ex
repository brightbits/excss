defmodule ExCss.Parser.Nodes.QualifiedRule do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens

  defstruct prelude: {}, block: nil

  def pretty_print(qualified_rule, indent) do
    PrettyPrint.pretty_out("Qualified Rule:", indent)
    PrettyPrint.pretty_out("Prelude:", indent + 1)

    state = ExCss.Parser.State.new(qualified_rule.prelude)
    {_, selector} = Nodes.Selector.parse(state)
    PrettyPrint.pretty_out(selector, indent + 2)

    state = ExCss.Parser.State.new(qualified_rule.block.value)
    {_, declaration_list} = Nodes.DeclarationList.parse(state)
    PrettyPrint.pretty_out(declaration_list, indent + 1)
  end

  def parse(state) do
    consume_a_qualified_rule(state)
  end

  defp consume_a_qualified_rule(state) do
    state |> State.debug("-- CONSUMING A QUALIFIED RULE --")
    state = State.consume_whitespace(state)

    {state, rule} = consume_a_qualified_rule(state, %Nodes.QualifiedRule{prelude: []})

    if rule do
      prelude =
        rule.prelude
        |> Enum.reverse
        |> List.to_tuple

      {state, %{rule | prelude: prelude}}
    else
      {state, rule}
    end
  end
  defp consume_a_qualified_rule(state, rule) do
    # Create a new qualified rule with its prelude initially set to an empty list, and its value initially set to nothing.
    #
    # Repeatedly consume the next input token:
    #
    # <EOF-token>
    # This is a parse error. Return nothing.
    # <{-token>
    # Consume a simple block and assign it to the qualified rule’s block. Return the qualified rule.
    # simple block with an associated token of <{-token>
    # Assign the block to the qualified rule’s block. Return the qualified rule.
    # anything else
    # Reconsume the current input token. Consume a component value. Append the returned value to the qualified rule’s prelude.

    if state |> State.currently?(Tokens.EndOfFile) do
      {state, nil}
    else
      cond do
        State.currently_simple_block?(state) ->
          {state, %{rule | block: state.token}}
        state |> State.currently?(Tokens.OpenCurly) ->
          {state, simple_block} = Nodes.SimpleBlock.parse(state)
          {state, %{rule | block: simple_block}}
        true ->
          {state, component_value} = State.consume_component_value(state)

          consume_a_qualified_rule(state, %{rule | prelude: [component_value] ++ rule.prelude})
      end
    end
  end
end
