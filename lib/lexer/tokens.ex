defmodule ExCss.Lexer.Token do
  def type(token) do
    token.__struct__
  end

  def to_pretty(token) do
    type(token).to_pretty(token)
  end
end

defmodule ExCss.Lexer.Tokens.AtKeyword do
  defstruct value: nil

  def to_pretty(_), do: "<AT KEYWORD>"
end

defmodule ExCss.Lexer.Tokens.CloseCurly do
   defstruct []

   def to_pretty(_), do: "<}>"
end

defmodule ExCss.Lexer.Tokens.CloseParenthesis do
  defstruct []

  def to_pretty(_), do: "<)>"
end

defmodule ExCss.Lexer.Tokens.CloseSquare do
  defstruct []

  def to_pretty(_), do: "<]>"
end

defmodule ExCss.Lexer.Tokens.Colon do
  defstruct []

  def to_pretty(_), do: "<:>"
end

defmodule ExCss.Lexer.Tokens.Comma do
  defstruct []

  def to_pretty(_), do: "<,>"
end

defmodule ExCss.Lexer.Tokens.Comment do
  defstruct value: nil

  def to_pretty(_), do: "<COMMENT>"
end

defmodule ExCss.Lexer.Tokens.Column do
  defstruct []

  def to_pretty(_), do: "<||>"
end

defmodule ExCss.Lexer.Tokens.DashMatch do
  defstruct []

  def to_pretty(_), do: "<DASH MATCH>"
end

defmodule ExCss.Lexer.Tokens.Delim do
  defstruct value: nil

  def to_pretty(token), do: "<DELIM '#{token.value}'>"
end

defmodule ExCss.Lexer.Tokens.Number do
  defstruct value: nil, original_value: nil

  def to_pretty(token), do: "<NUMBER #{token.value}>"
end

defmodule ExCss.Lexer.Tokens.Percentage do
  defstruct value: nil, original_value: nil

  def to_pretty(token), do: "<PERCENTAGE #{token.value}%>"
end

defmodule ExCss.Lexer.Tokens.Dimension do
  defstruct value: nil, original_value: nil, unit: nil

  def to_pretty(token), do: "<DIMENSION #{token.value} #{token.unit}>"
end

defmodule ExCss.Lexer.Tokens.Hash do
  defstruct value: nil, id: false

  def to_pretty(token = %ExCss.Lexer.Tokens.Hash{id: true}), do: "<HASH-ID #{token.value}>"
  def to_pretty(token = %ExCss.Lexer.Tokens.Hash{id: false}), do: "<HASH #{token.value}>"
end

defmodule ExCss.Lexer.Tokens.Id do
  defstruct value: nil

  def to_pretty(token), do: "<ID #{token.value}>"
end

defmodule ExCss.Lexer.Tokens.Function do
  defstruct value: nil

  def to_pretty(token), do: "<FUNCTION #{token.value}>"
end

defmodule ExCss.Lexer.Tokens.Url do
  defstruct value: nil

  def to_pretty(token), do: "<URL #{token.value}>"
end

defmodule ExCss.Lexer.Tokens.BadUrl do
  defstruct []

  def to_pretty(_), do: "<BAD URL>"
end

defmodule ExCss.Lexer.Tokens.IncludeMatch do
  defstruct []

  def to_pretty(_), do: "<INCLUDE MATCH>"
end

defmodule ExCss.Lexer.Tokens.CDC do
  defstruct []

  def to_pretty(_), do: "<CDC>"
end

defmodule ExCss.Lexer.Tokens.CDO do
  defstruct []

  def to_pretty(_), do: "<CDO>"
end

defmodule ExCss.Lexer.Tokens.OpenCurly do
  defstruct []

  def to_pretty(_), do: "<{>"
end

defmodule ExCss.Lexer.Tokens.OpenParenthesis do
  defstruct []

  def to_pretty(_), do: "<(>"
end

defmodule ExCss.Lexer.Tokens.OpenSquare do
  defstruct []

  def to_pretty(_), do: "<[>"
end

defmodule ExCss.Lexer.Tokens.PrefixMatch do
  defstruct []

  def to_pretty(_), do: "<PREFIX MATCH>"
end

defmodule ExCss.Lexer.Tokens.Semicolon do
  defstruct []

  def to_pretty(_), do: "<;>"
end

defmodule ExCss.Lexer.Tokens.String do
  defstruct value: nil, wrapped_by: nil

  def to_pretty(token), do: "<STRING #{token.wrapped_by}#{token.value}#{token.wrapped_by}>"
end

defmodule ExCss.Lexer.Tokens.BadString do
  defstruct []

  def to_pretty(_), do: "<BAD STRING>"
end

defmodule ExCss.Lexer.Tokens.SubstringMatch do
  defstruct []

  def to_pretty(_), do: "<SUBSTRING MATCH>"
end

defmodule ExCss.Lexer.Tokens.SuffixMatch do
  defstruct []

  def to_pretty(_), do: "<SUFFIX MATCH>"
end

defmodule ExCss.Lexer.Tokens.Whitespace do
  defstruct []

  def to_pretty(_), do: "<WS>"
end

defmodule ExCss.Lexer.Tokens.EndOfFile do
  defstruct []

  def to_pretty(_), do: "<EOF>"
end
