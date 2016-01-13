defmodule ExCss.Parser do
  alias ExCss.Parser.State, as: PS

  def parse(str) do
    parse_stylesheet(PS.new(str))
  end

  defp parse_stylesheet(state) do
    # Create a new stylesheet.
    # Consume a list of rules from the stream of tokens, with the top-level flag set.
    # Assign the returned value to the stylesheet’s value.
    # Return the stylesheet.
    IO.puts "\n\n\n-- PARSING STYLESHEET --"
    {state, list_of_rules} = consume_a_list_of_rules(state, true)
    %ExCss.Parser.Stylesheet{rules: list_of_rules}
  end

  defp parse_a_list_of_rules(state, top_level) do
    IO.puts "-- PARSING A LIST OF RULES --"
    # Consume a list of rules from the stream of tokens, with the top-level flag unset.
    # Return the returned list.
    consume_a_list_of_rules(state, false, [])
  end

  defp parse_a_rule(state) do
    IO.puts "-- PARSING A RULE --"
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return a syntax error.
    # Otherwise, if the current input token is an <at-keyword-token>, consume an at-rule and let rule be the return value.
    #
    # Otherwise, consume a qualified rule and let rule be the return value. If nothing was returned, return a syntax error.
    #
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return rule. Otherwise, return a syntax error.
    state = state |> PS.consume_ignoring_whitespace
    rule = nil

    if state |> PS.currently?(:eof) do
      raise "Syntax error: end of file reached while parsing a rule"
    end

    if state |> PS.currently?(:at_keyword) do
      {state, rule} = state |> consume_an_at_rule
    else
      {state, rule} = state |> consume_a_qualified_rule
      unless rule do
        raise "Syntax error: Expected a qualified rule, but didn't get one"
      end
    end

    state = state |> PS.consume_ignoring_whitespace

    if state |> PS.not_currently?(:eof) do
      raise "Syntax error: Expected end of file"
    end

    {state, rule}
  end

  defp parse_a_declaration(state) do
    IO.puts "-- PARSING A DECLARATION --"
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is not an <ident-token>, return a syntax error.
    # Consume a declaration. If anything was returned, return it. Otherwise, return a syntax error.
    state = state |> PS.consume_ignoring_whitespace
    declaration = nil

    if state |> PS.currently?(:id) do
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
    IO.puts "-- PARSING A COMPONENT VALUE --"
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return a syntax error.
    # Reconsume the current input token. Consume a component value and let value be the return value. If nothing is returned, return a syntax error.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is an <EOF-token>, return value. Otherwise, return a syntax error.
    state |> PS.consume_ignoring_whitespace

    if state |> PS.currently?(:eof) do
      raise "Syntax error: Expected a component value, but got end of file"
    end

    state = state |> PS.reconsume

    {state, component_value} = state |> consume_a_component_value

    unless component_value do
      raise "Syntax error: expected a component value but didn't get one"
    end

    state = state |> PS.consume_ignoring_whitespace

    if state |> PS.not_currently?(:eof) do
      raise "Syntax error: expected end of file"
    end

    {state, component_value}
  end

  defp parse_a_list_of_component_values(state) do
    IO.puts "-- PARSING A LIST OF COMPONENT VALUES --"
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
    IO.puts "-- CONSUMING A LIST OF RULES --"
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

    state = state |> PS.consume_ignoring_whitespace
    token_type = PS.token_type(state)
    cond do
      token_type == :eof ->
        {state, rules}
      token_type == :cdo || token_type == :cdc ->
        unless top_level do
          {state, qualified_rule} = state
          |> PS.reconsume
          |> consume_a_qualified_rule

          rules = rules ++ [qualified_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)

      token_type == :at_keyword ->
        {state, at_rule} = state
        |> PS.reconsume
        |> consume_an_at_rule

        if at_rule do
          rules = rules ++ [at_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)

      true ->
        {state, qualified_rule} = state
        |> PS.reconsume
        |> consume_a_qualified_rule

        if qualified_rule do
          rules = rules ++ [qualified_rule]
        end

        consume_a_list_of_rules(state, top_level, rules)
    end
  end

  defp consume_an_at_rule(state) do
    IO.puts "-- CONSUMING AN AT RULE --"
    consume_an_at_rule(state, %ExCss.Parser.AtRule{name: state.token})
  end
  defp consume_an_at_rule(state, rule) do
    # Create a new at-rule with its name set to the value of the current input token,
    # its prelude initially set to an empty list, and its value initially set to nothing.
    #
    # Repeatedly consume the next input token:
    #
    # <semicolon-token>
    # <EOF-token>
    # Return the at-rule.
    # <{-token>
    # Consume a simple block and assign it to the at-rule’s block. Return the at-rule.
    # simple block with an associated token of <{-token>
    # Assign the block to the at-rule’s block. Return the at-rule.
    # anything else
    # Reconsume the current input token. Consume a component value. Append the returned value to the at-rule’s prelude.
    state = state |> PS.consume

    if PS.currently?(state, :semicolon) || PS.currently?(state, :eof) do
      {state, rule}
    else
      if state |> PS.currently?(:open_curly) do
        {state, simple_block} = state |> consume_a_simple_block
        rule = %{rule | block: simple_block}
        {state, rule}
      else
        state = state |> PS.reconsume
        {state, component_value} = state |> consume_a_component_value
        rule = %{rule | prelude: rule.prelude ++ [component_value]}

        consume_an_at_rule(state, rule)
      end
    end
  end

  defp consume_a_qualified_rule(state) do
    IO.puts "-- CONSUMING A QUALIFIED RULE --"
    consume_a_qualified_rule(state, %ExCss.Parser.QualifiedRule{})
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

    state = state |> PS.consume
    if state |> PS.currently?(:eof) do
      raise "Parse error! Not sure if we should raise here or return nil"
    end

    cond do
      PS.currently_simple_block?(state) ->
        rule = %{rule | block: state.token}
        {state, rule}
      state |> PS.currently?(:open_curly) ->
        {state, simple_block} = state |> consume_a_simple_block
        rule = %{rule | block: simple_block}
        {state, rule}
      true ->
        {state, component_value} = state |> PS.reconsume |> consume_a_component_value
        rule = %{rule | prelude: rule.prelude ++ [component_value]}

        consume_a_qualified_rule(state, rule)
    end
  end

  defp consume_a_list_of_declarations(state) do
    IO.puts "-- CONSUMING A LIST OF DECLARATIONS --"
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

    state = state |> PS.consume_ignoring_whitespace

    case state |> PS.token_type do
      :eof ->
        {state, declarations}
      :semicolon ->
        consume_a_list_of_declarations(state, declarations)
      :at_keyword ->
        {state, at_rule} = state |> consume_an_at_rule
        consume_a_list_of_declarations(state, declarations ++ [at_rule])
      :id ->
        {state, temp_list} = consume_temp_list_for_declaration(state, [state.token])
        temp_state = PS.for_declaration(temp_list)

        {_, declaration} = temp_state |> consume_a_declaration

        if declaration do
          declarations = declarations ++ declaration
        end

        consume_a_list_of_declarations(state, declarations)
    end
  end

  defp consume_temp_list_for_declaration(state, temp_list) do
    state = state |> PS.consume
    token_type = state |> PS.token_type

    if token_type == :eof || token_type == :semicolon do
      {state |> PS.reconsume, temp_list}
    else
      {state, component_value} = state |> consume_a_component_value
      consume_temp_list_for_declaration(state, temp_list ++ [component_value])
    end
  end

  defp consume_a_declaration(state) do
    IO.puts "-- CONSUMING A DECLARATION --"
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is anything other than a <colon-token>, this is a parse error. Return nothing.
    state = state |> PS.consume_ignoring_whitespace

    if state |> PS.not_currently?(:colon) do
      raise "Parse error: expected a colon for the declaration"
    end

    {state, declaration} = consume_a_declaration(state, %ExCss.Parser.Declaration{name: state.token})

    # If the last two non-<whitespace-token>s in the declaration’s value are a <delim-token> with the value "!" followed by an <ident-token> with a value that is an ASCII case-insensitive match for "important", remove them from the declaration’s value and set the declaration’s important flag to true.
    # Return the declaration.
    if length(declaration) > 2 do
      [last_value | tail] = declaration.value
      [next_to_last_value | tail] = tail

      if elem(last_value, 0) == :id do
        {_, {last_value_value}} = last_value

        if String.downcase(last_value_value) == "important" && next_to_last_value == {:delim, {"!"}} do
          declaration = %{declaration | important: true}
        end
      end
    end

    declaration = %{declaration | values: Enum.reverse(declaration.value)}
    {state, declaration}
  end
  defp consume_a_declaration(state, declaration) do
    # Otherwise, consume the next input token.
    #
    # While the current input token is anything other than an <EOF-token>,
    # append it to the declaration’s value and consume the next input token.
    state = state |> PS.consume

    if state |> PS.not_currently?(:eof) do
      {state, component_value} = state |> consume_a_component_value
      declaration = %{declaration | value: [component_value] ++ declaration.value}
      consume_a_declaration(state, declaration)
    else
      {state, declaration}
    end
  end

  defp consume_a_component_value(state) do
    IO.puts "-- CONSUMING A COMPONENT VALUE --"
    # Consume the next input token.
    #
    # If the current input token is a <{-token>, <[-token>, or <(-token>, consume a simple block and return it.
    #
    # Otherwise, if the current input token is a <function-token>, consume a function and return it.
    #
    # Otherwise, return the current input token.
    state = state |> PS.consume
    token_type = state |> PS.token_type

    cond do
      token_type == :open_curly || token_type == :open_square || token_type == :open_parenthesis ->
        consume_a_simple_block(state)
      token_type == :function ->
        consume_a_function(state)
      true ->
        {state, state.token}
    end
  end

  defp consume_a_simple_block(state) do
    IO.puts "-- CONSUMING A SIMPLE BLOCK --"
    # The ending token is the mirror variant of the current input token. (E.g. if it was called with <[-token>, the ending token is <]-token>.)
    #
    # Create a simple block with its associated token set to the current input token and with a value with is initially an empty list.
    ending_token_type = PS.token_mirror(state)
    consume_a_simple_block(state, ending_token_type, %ExCss.Parser.SimpleBlock{associated_token: state.token, value: []})
  end
  defp consume_a_simple_block(state, ending_token_type, simple_block) do
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # ending token
    # Return the block.
    # anything else
    # Reconsume the current input token. Consume a component value and append it to the value of the block.

    state = state |> PS.consume
    token_type = state |> PS.token_type

    if token_type == :eof || token_type == ending_token_type do
      {state, simple_block}
    else
      {state, component_value} = state |> PS.reconsume |> consume_a_component_value

      consume_a_simple_block(state, ending_token_type, %{simple_block | value: simple_block.value ++ [component_value]})
    end
  end

  defp consume_a_function(state) do
    IO.puts "-- CONSUMING A FUNCTION --"
    consume_a_function(state, %ExCss.Parser.Function{name: state.token, value: []})
  end
  defp consume_a_function(state, function) do
    # Create a function with a name equal to the value of the current input token, and with a value which is initially an empty list.
    #
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # <)-token>
    # Return the function.
    # anything else
    # Reconsume the current input token. Consume a component value and append the returned value to the function’s value.
    state = state |> PS.consume
    token_type = state |> PS.token_type

    if token_type == :eof || token_type == :close_parenthesis do
    else
      {state, component_value} = state |> PS.reconsume |> consume_a_component_value
      consume_a_function(state, %{function | value: function.value ++ [component_value]})
    end
  end
end
