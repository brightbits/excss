defmodule ExCss.Lexer.Consumers.CloseCurly do
  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  def accept(state) do
    if State.peek(state) == "}" do
      state = State.consume(state)
      {state, %Tokens.CloseCurly{}}
    else
      {state, nil}
    end
  end
end
