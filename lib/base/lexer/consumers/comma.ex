defmodule ExCss.Lexer.Consumers.Comma do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "," do
      state = State.consume(state)
      {state, %Tokens.Comma{}}
    else
      {state, nil}
    end
  end
end
