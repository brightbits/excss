defmodule ExCss.Parser.Nodes.Attribute do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct value: nil, match_token: nil, match_value: nil

  def pretty_print(attribute, indent) do
    PrettyPrint.pretty_out("Attribute:", indent)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(attribute.value, indent + 2)
    PrettyPrint.pretty_out("Match Token:", indent + 1)
    PrettyPrint.pretty_out(attribute.match_token, indent + 2)
    PrettyPrint.pretty_out("Match Value:", indent + 1)
    PrettyPrint.pretty_out(attribute.match_value, indent + 2)
  end

  # '[' S* [ namespace_prefix ]? IDENT S*
  #         [ [ PREFIXMATCH |
  #             SUFFIXMATCH |
  #             SUBSTRINGMATCH |
  #             '=' |
  #             INCLUDES |
  #             DASHMATCH ] S* [ IDENT | STRING ] S*
  #         ]? ']'
  def parse(state) do
    state = State.consume_ignoring_whitespace(state)

    if State.currently?(state, T.Id) do
      attribute = %N.Attribute{value: state.token.value}

      state = State.consume_ignoring_whitespace(state)

      if match_token?(state) do
        consume_match(state, attribute)
      else
        consume_close(state, attribute)
      end
    else
      {state, nil}
    end
  end

  defp consume_match(state, attribute) do
    attribute = %{attribute | match_token: state.token}

    state = State.consume_ignoring_whitespace(state)

    if State.currently?(state, [T.Id, T.String]) do
      attribute = %{attribute | match_value: state.token.value}

      state
      |> State.consume_ignoring_whitespace
      |> consume_close(attribute)
    else
      {state, nil}
    end
  end

  defp consume_close(state, attribute) do
    if State.currently?(state, T.CloseSquare) do
      {State.consume(state), attribute}
    else
      {state, nil}
    end
  end

  defp match_token?(state) do
    State.currently?(state, T.Delim, "=") || State.currently?(state, [
      T.PrefixMatch,
      T.SuffixMatch,
      T.SubstringMatch,
      T.IncludeMatch,
      T.DashMatch
    ])
  end
end
