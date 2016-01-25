defmodule ExCss.Lexer.Consumers.At do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "@" do
      state = State.consume(state)

      if start_of_identifier?(State.peek(state), State.peek(state), State.peek(state)) do
        {state, name} = consume_name(state)

        {state, %Tokens.AtKeyword{value: name}}
      else
        {state, %Tokens.Delim{value: "@"}}
      end
    else
      {state, nil}
    end
  end
end
