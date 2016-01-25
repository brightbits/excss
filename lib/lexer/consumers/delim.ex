defmodule ExCss.Lexer.Consumers.Delim do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if end_of_file?(State.peek(state)) do
      {state, %Tokens.EndOfFile{}}
    else
      state = State.consume(state)
      {state, %Tokens.Delim{value: state.grapheme}}
    end
  end
end
