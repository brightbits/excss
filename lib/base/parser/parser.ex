defmodule ExCss.Parser do
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens

  def parse(str, opts \\ [specifications: [ExCss.Selectors]]) do
    {_, stylesheet} = Nodes.Stylesheet.parse(State.new(str, opts))
    stylesheet
  end

  defp parse_a_list_of_rules(state) do
    # Consume a list of rules from the stream of tokens, with the top-level flag unset.
    # Return the returned list.
    {_, rule_list} = Nodes.RuleList.parse(state, false)
  end

  defp parse_a_rule(state) do
    state |> State.debug("-- PARSING A RULE --")
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return a syntax error.
    # Otherwise, if the current input token is an <at-keyword-token>, consume an at-rule and let rule be the return value.
    #
    # Otherwise, consume a qualified rule and let rule be the return value. If nothing was returned, return a syntax error.
    #
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return rule. Otherwise, return a syntax error.
    state = state |> State.consume_ignoring_whitespace
    rule = nil

    if state |> State.currently?(Tokens.EndOfFile) do
      raise "Syntax error: end of file reached while parsing a rule"
    end

    if state |> State.currently?(Tokens.AtKeyword) do
      {state, rule} = state |> Nodes.AtRule.parse
    else
      {state, rule} = state |> consume_a_qualified_rule
      unless rule do
        raise "Syntax error: Expected a qualified rule, but didn't get one"
      end
    end

    state = state |> State.consume_ignoring_whitespace

    if state |> State.not_currently?(Tokens.EndOfFile) do
      raise "Syntax error: Expected end of file"
    end

    {state, rule}
  end

  defp parse_a_declaration(state) do
    state |> State.debug("-- PARSING A DECLARATION --")
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is not an <ident-token>, return a syntax error.
    # Consume a declaration. If anything was returned, return it. Otherwise, return a syntax error.
    state = state |> State.consume_ignoring_whitespace
    declaration = nil

    if state |> State.currently?(Tokens.Id) do
      {state, declaration} = state |> consume_a_declaration
    else
      raise "Syntax error: Expected an id"
    end

    if declaration do
      {state, declaration}
    else
      raise "Syntax error: Expected a declaration but didn't get one"
    end
  end

  defp parse_a_component_value(state) do
    state |> State.debug("-- PARSING A COMPONENT VALUE --")
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return a syntax error.
    # Reconsume the current input token. Consume a component value and let value be the return value. If nothing is returned, return a syntax error.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return value. Otherwise, return a syntax error.
    state |> State.consume_ignoring_whitespace

    if state |> State.currently?(Tokens.EndOfFile) do
      raise "Syntax error: Expected a component value, but got end of file"
    end

    state = state |> State.reconsume

    {state, component_value} = State.consume_component_value(state)

    unless component_value do
      raise "Syntax error: expected a component value but didn't get one"
    end

    state = state |> State.consume_ignoring_whitespace

    if state |> State.not_currently?(Tokens.EndOfFile) do
      raise "Syntax error: expected end of file"
    end

    {state, component_value}
  end

  defp parse_a_list_of_component_values(state) do
    state |> State.debug("-- PARSING A LIST OF COMPONENT VALUES --")
    {state, list} = parse_a_list_of_component_values(state, [])
    {state, List.to_tuple(list)}
  end
  defp parse_a_list_of_component_values(state, values) do
    # Repeatedly consume a component value until an <EOF-token> is returned,
    # appending the returned values (except the final <EOF-token>) into a list. Return the list.

    {state, component_value} = State.consume_component_value(state)

    if component_value == :eof do
      {state, values}
    else
      parse_a_list_of_component_values(state, values ++ [component_value])
    end
  end
end
