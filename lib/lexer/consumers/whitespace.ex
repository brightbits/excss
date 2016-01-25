defmodule ExCss.Lexer.Consumers.Whitespace do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if whitespace?(State.peek(state)) do
      {consume_until_not_whitespace(state), %Tokens.Whitespace{}}
    else
      {state, nil}
    end
  end

  defp consume_until_not_whitespace(state) do
    if whitespace?(State.peek(state)) do
      state
      |> State.consume
      |> consume_until_not_whitespace
    else
      state
    end
  end
end
