defmodule ExCss.Lexer.Consumers.Digits do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.State

  def accept(state) do
    if digit?(State.peek(state)) do
      consume_numeric(state)
    else
      {state, nil}
    end
  end
end
