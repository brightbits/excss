defmodule ExCss.Lexer do
  def new(str) do
    %{str: str, pos: -1, warnings: []}
  end

  def next(state) do
    state |> visit_consumers([
      ExCss.Lexer.Consumers.Comment,
      ExCss.Lexer.Consumers.Whitespace,
      ExCss.Lexer.Consumers.String,
      ExCss.Lexer.Consumers.Hash,
      ExCss.Lexer.Consumers.SuffixMatch,
      ExCss.Lexer.Consumers.OpenParenthesis,
      ExCss.Lexer.Consumers.CloseParenthesis,
      ExCss.Lexer.Consumers.SubstringMatch,
      ExCss.Lexer.Consumers.Plus,
      ExCss.Lexer.Consumers.Comma,
      ExCss.Lexer.Consumers.Minus,
      ExCss.Lexer.Consumers.Period,
      ExCss.Lexer.Consumers.Colon,
      ExCss.Lexer.Consumers.Semicolon,
      ExCss.Lexer.Consumers.OpenArrow,
      ExCss.Lexer.Consumers.At,
      ExCss.Lexer.Consumers.OpenSquare,
      ExCss.Lexer.Consumers.LiteralEscape,
      ExCss.Lexer.Consumers.CloseSquare,
      ExCss.Lexer.Consumers.PrefixMatch,
      ExCss.Lexer.Consumers.OpenCurly,
      ExCss.Lexer.Consumers.DashMatch,
      ExCss.Lexer.Consumers.CloseCurly,
      ExCss.Lexer.Consumers.Digits,
      ExCss.Lexer.Consumers.Ids,
      ExCss.Lexer.Consumers.Delim
    ])
  end

  def do_it(str) do
    tokens = read_tokens(new(str), [])
    IO.puts "Token count: #{length(tokens)}"
    tokens
  end

  defp read_tokens(state, tokens) do
    {state, {type, _} = token} = next(state)

    cond do
      type == :eof ->
        List.to_tuple(Enum.reverse([token] ++ tokens))
      true ->
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
