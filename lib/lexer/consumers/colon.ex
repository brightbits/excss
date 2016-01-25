defmodule ExCss.Lexer.Consumers.Colon do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == ":" do
      state = State.consume(state)
      {state, %Tokens.Colon{}}
    else
      {state, nil}
    end
  end
end
