defmodule ExCss.Utils.PrettyPrint do
  def pretty_out(str, indent) do
    IO.puts "#{String.ljust("", indent * 2, ?\s)}#{str}"
  end

  def tokens(toks) when is_tuple(toks), do: tokens(Tuple.to_list(toks))
  def tokens([]), do: nil
  def tokens([token | tail]) do
    IO.puts ExCss.Lexer.Token.to_pretty(token)
    tokens(tail)
  end
end
