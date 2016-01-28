defmodule ExCss.Lexer.Consumers.DashMatch do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "|" do
      state = State.consume(state)
      cond do
        State.peek(state) == "=" ->
          {State.consume(state), %Tokens.DashMatch{}}
        State.peek(state) == "|" ->
          {State.consume(state), %Tokens.Column{}}
        true ->
          {state, %Tokens.Delim{value: "|"}}
      end
    else
      {state, nil}
    end
  end
end
