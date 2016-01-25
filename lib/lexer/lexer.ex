defmodule ExCss.Lexer do
  alias ExCss.Lexer.State
  alias ExCss.Lexer.Consumers
  alias ExCss.Lexer.Token
  alias ExCss.Lexer.Tokens

  def next(state) do
    state |> visit_consumers([
      Consumers.Comment,
      Consumers.Whitespace,
      Consumers.String,
      Consumers.Hash,
      Consumers.SuffixMatch,
      Consumers.OpenParenthesis,
      Consumers.CloseParenthesis,
      Consumers.SubstringMatch,
      Consumers.Plus,
      Consumers.Comma,
      Consumers.Minus,
      Consumers.Period,
      Consumers.Colon,
      Consumers.Semicolon,
      Consumers.OpenArrow,
      Consumers.At,
      Consumers.OpenSquare,
      Consumers.LiteralEscape,
      Consumers.CloseSquare,
      Consumers.PrefixMatch,
      Consumers.OpenCurly,
      Consumers.DashMatch,
      Consumers.CloseCurly,
      Consumers.Digits,
      Consumers.Ids,
      Consumers.Delim
    ])
  end

  def lex(str) do
    state = State.new(str)
    read_tokens(state, [])
  end

  defp read_tokens(state, tokens) do
    {state, token} = next(state)

    if Token.type(token) == Tokens.EndOfFile do
      List.to_tuple(Enum.reverse([token] ++ tokens))
    else
      read_tokens(state, [token] ++ tokens)
    end
  end

  defp visit_consumers(_, []), do: raise "Unable to match the input to a consumer"
  defp visit_consumers(state, [consumer | consumers]) do
    {state, token} = state |> consumer.accept

    case token do
      nil ->
        state |> visit_consumers(consumers)
      token ->
        {state, token}
    end
  end
end
