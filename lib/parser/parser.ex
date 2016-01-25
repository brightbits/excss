defmodule ExCss.Parser do
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.Token
  alias ExCss.Utils.Log

  def parse(str) do
    parse_stylesheet(State.new(str))
  end

  defp parse_stylesheet(state) do
    # Create a new stylesheet.
    # Consume a list of rules from the stream of tokens, with the top-level flag set.
    # Assign the returned value to the stylesheet’s value.
    # Return the stylesheet.
    Log.debug "-- PARSING STYLESHEET --"
    {_, list_of_rules} = consume_a_list_of_rules(state, true)
    %ExCss.Parser.Stylesheet{rules: list_of_rules}
  end

  defp parse_a_list_of_rules(state, top_level) do
    Log.debug "-- PARSING A LIST OF RULES --"
    # Consume a list of rules from the stream of tokens, with the top-level flag unset.
    # Return the returned list.
    consume_a_list_of_rules(state, false, [])
  end

  defp parse_a_rule(state) do
    Log.debug "-- PARSING A RULE --"
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
    Log.debug "-- PARSING A DECLARATION --"
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
    Log.debug "-- PARSING A COMPONENT VALUE --"
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

    {state, component_value} = state |> consume_a_component_value

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
    Log.debug "-- PARSING A LIST OF COMPONENT VALUES --"
    {state, list} = parse_a_list_of_component_values(state, [])
    {state, List.to_tuple(list)}
  end
  defp parse_a_list_of_component_values(state, values) do
    # Repeatedly consume a component value until an <EOF-token> is returned,
    # appending the returned values (except the final <EOF-token>) into a list. Return the list.

    {state, component_value} = state |> consume_a_component_value

    if component_value == :eof do
      {state, values}
    else
      parse_a_list_of_component_values(state, values ++ [component_value])
    end
  end

  defp consume_a_list_of_rules(state, top_level) do
    Log.debug "-- CONSUMING A LIST OF RULES --"
    {state, list} = consume_a_list_of_rules(state, top_level, [])
    {state, List.to_tuple(list)}
  end
  defp consume_a_list_of_rules(state, top_level, rules) do
    # Create an initially empty list of rules.
    #
    # Repeatedly consume the next input token:
    #
    # <whitespace-token>
    # Do nothing.
    # <EOF-token>
    # Return the list of rules.
    # <CDO-token>
    # <CDC-token>
    # If the top-level flag is set, do nothing.
    # Otherwise, reconsume the current input token. Consume a qualified rule. If anything is returned, append it to the list of rules.
    #
    # <at-keyword-token>
    # Reconsume the current input token. Consume an at-rule. If anything is returned, append it to the list of rules.
    # anything else
    # Reconsume the current input token. Consume a qualified rule. If anything is returned, append it to the list of rules.

    state = state |> State.consume_ignoring_whitespace
    token_type = Token.type(state.token)
    cond do
      token_type == Tokens.EndOfFile ->
        {state, rules}
      token_type == Tokens.CDO || token_type == Tokens.CDC ->
        unless top_level do
          {state, qualified_rule} = state
          |> State.reconsume
          |> Nodes.QualifiedRule.parse

          rules = rules ++ [qualified_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)

      token_type == Tokens.AtKeyword ->
        {state, at_rule} = state
        |> Nodes.AtRule.parse

        if at_rule do
          rules = rules ++ [at_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)

      true ->
        {state, qualified_rule} = state
        |> State.reconsume
        |> Nodes.QualifiedRule.parse

        if qualified_rule do
          rules = rules ++ [qualified_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)
    end
  end

  def consume_a_list_of_declarations(state) do
    Log.debug "-- CONSUMING A LIST OF DECLARATIONS --"
    {state, list} = consume_a_list_of_declarations(state, [])
    {state, List.to_tuple(list)}
  end
  defp consume_a_list_of_declarations(state, declarations) do
    # Create an initially empty list of declarations.
    #
    # Repeatedly consume the next input token:
    #
    # <whitespace-token>
    # <semicolon-token>
    # Do nothing.
    # <EOF-token>
    # Return the list of declarations.
    # <at-keyword-token>
    # Consume an at-rule. Append the returned rule to the list of declarations.
    # <ident-token>
    # Initialize a temporary list initially filled with the current input token.
    # Consume the next input token. While the current input token is anything other than a
    # <semicolon-token> or <EOF-token>, append it to the temporary list and consume the next input token.
    # Consume a declaration from the temporary list. If anything was returned, append it to the list of declarations.
    # anything else
    # This is a parse error. Repeatedly consume a component value until it is a <semicolon-token> or <EOF-token>.

    state = state |> State.consume_ignoring_whitespace

    case Token.type(state.token) do
      Tokens.EndOfFile ->
        {state, declarations}
      Tokens.Semicolon ->
        consume_a_list_of_declarations(state, declarations)
      Tokens.AtKeyword ->
        {state, at_rule} = state |> Nodes.AtRule.parse
        consume_a_list_of_declarations(state, declarations ++ [at_rule])
      Tokens.Id ->
        {state, temp_list} = consume_temp_list_for_declaration(state, [state.token])

        temp_state = State.new(temp_list)

        {_, declaration} = temp_state |> Nodes.Declaration.parse

        if declaration do
          declarations = declarations ++ [declaration]
        end

        consume_a_list_of_declarations(state, declarations)
      _ ->
        state |> State.debug
    end
  end

  defp consume_temp_list_for_declaration(state, temp_list) do
    state = state |> State.consume

    if State.currently?(state, [Tokens.EndOfFile, Tokens.Semicolon]) do
      {state, temp_list}
    else
      {state, component_value} = state |> State.reconsume |> consume_a_component_value
      consume_temp_list_for_declaration(state, temp_list ++ [component_value])
    end
  end

  def consume_a_component_value(state) do
    #Log.debug "-- CONSUMING A COMPONENT VALUE --"
    # Consume the next input token.
    #
    # If the current input token is a <{-token>, <[-token>, or <(-token>, consume a simple block and return it.
    #
    # Otherwise, if the current input token is a <function-token>, consume a function and return it.
    #
    # Otherwise, return the current input token.
    state = state |> State.consume
    token_type = Token.type(state.token)

    cond do
      token_type == Tokens.OpenCurly || token_type == Tokens.OpenSquare || token_type == Tokens.OpenParenthesis ->
        Nodes.SimpleBlock.parse(state)
      token_type == Tokens.Function ->
        Nodes.Function.parse(state)
      true ->
        {state, state.token}
    end
  end
end
