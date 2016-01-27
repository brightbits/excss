defmodule ExCss.Parser.Nodes.RuleList do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Token
  alias ExCss.Lexer.Tokens
  defstruct rules: []

  def pretty_print(rule_list, indent) do
    PrettyPrint.pretty_out("Rule List:", indent)
    PrettyPrint.pretty_out("Rules:", indent + 1)
    PrettyPrint.pretty_out(rule_list.rules, indent + 2)
  end

  def parse(state, top_level \\ false) do
    {state, rules} = consume_a_list_of_rules(state, top_level)
    {state, %Nodes.RuleList{rules: rules}}
  end

  defp consume_a_list_of_rules(state, top_level) do
    state |> State.debug("-- CONSUMING A LIST OF RULES --")
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

end
