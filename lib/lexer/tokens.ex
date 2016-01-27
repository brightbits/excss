defmodule ExCss.Lexer.Token do
  def type(token) do
    token.__struct__
  end

  def pretty_print(str, indent) do
    ExCss.Utils.PrettyPrint.pretty_out(str, indent)
  end
end

defmodule ExCss.Lexer.Tokens.AtKeyword do
  defstruct value: nil

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<AT KEYWORD>", indent)
end

defmodule ExCss.Lexer.Tokens.CloseCurly do
   defstruct []

   def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<}>", indent)
end

defmodule ExCss.Lexer.Tokens.CloseParenthesis do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<)>", indent)
end

defmodule ExCss.Lexer.Tokens.CloseSquare do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<]>", indent)
end

defmodule ExCss.Lexer.Tokens.Colon do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<:>", indent)
end

defmodule ExCss.Lexer.Tokens.Comma do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<,>", indent)
end

defmodule ExCss.Lexer.Tokens.Comment do
  defstruct value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<COMMENT #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.Column do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<||>", indent)
end

defmodule ExCss.Lexer.Tokens.DashMatch do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<DASH MATCH>", indent)
end

defmodule ExCss.Lexer.Tokens.Delim do
  defstruct value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<DELIM '#{token.value}'>", indent)
end

defmodule ExCss.Lexer.Tokens.Number do
  defstruct value: nil, original_value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<NUMBER #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.Percentage do
  defstruct value: nil, original_value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<PERCENTAGE #{token.value}%>", indent)
end

defmodule ExCss.Lexer.Tokens.Dimension do
  defstruct value: nil, original_value: nil, unit: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<DIMENSION #{token.value} #{token.unit}>", indent)
end

defmodule ExCss.Lexer.Tokens.Hash do
  defstruct value: nil, id: false

  def pretty_print(token = %ExCss.Lexer.Tokens.Hash{id: true}, indent), do: ExCss.Lexer.Token.pretty_print("<HASH-ID #{token.value}>", indent)
  def pretty_print(token = %ExCss.Lexer.Tokens.Hash{id: false}, indent), do: ExCss.Lexer.Token.pretty_print("<HASH #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.Id do
  defstruct value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<ID #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.Function do
  defstruct value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<FUNCTION #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.Url do
  defstruct value: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<URL #{token.value}>", indent)
end

defmodule ExCss.Lexer.Tokens.BadUrl do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<BAD URL>", indent)
end

defmodule ExCss.Lexer.Tokens.IncludeMatch do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<INCLUDE MATCH>", indent)
end

defmodule ExCss.Lexer.Tokens.CDC do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<CDC>", indent)
end

defmodule ExCss.Lexer.Tokens.CDO do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<CDO>", indent)
end

defmodule ExCss.Lexer.Tokens.OpenCurly do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<{>", indent)
end

defmodule ExCss.Lexer.Tokens.OpenParenthesis do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<(>", indent)
end

defmodule ExCss.Lexer.Tokens.OpenSquare do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<[>", indent)
end

defmodule ExCss.Lexer.Tokens.PrefixMatch do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<PREFIX MATCH>", indent)
end

defmodule ExCss.Lexer.Tokens.Semicolon do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<;>", indent)
end

defmodule ExCss.Lexer.Tokens.String do
  defstruct value: nil, wrapped_by: nil

  def pretty_print(token, indent), do: ExCss.Lexer.Token.pretty_print("<STRING #{token.wrapped_by}#{token.value}#{token.wrapped_by}>", indent)
end

defmodule ExCss.Lexer.Tokens.BadString do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<BAD STRING>", indent)
end

defmodule ExCss.Lexer.Tokens.SubstringMatch do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<SUBSTRING MATCH>", indent)
end

defmodule ExCss.Lexer.Tokens.SuffixMatch do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<SUFFIX MATCH>", indent)
end

defmodule ExCss.Lexer.Tokens.Whitespace do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<WS>", indent)
end

defmodule ExCss.Lexer.Tokens.EndOfFile do
  defstruct []

  def pretty_print(_, indent), do: ExCss.Lexer.Token.pretty_print("<EOF>", indent)
end
