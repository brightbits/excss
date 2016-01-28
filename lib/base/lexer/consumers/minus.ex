defmodule ExCss.Lexer.Consumers.Minus do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "-" do
      state = State.consume(state)

      cond do
        start_of_number?(state.grapheme, State.peek(state), State.peek(state, 2)) ->
          consume_numeric(State.reconsume(state))
        State.peek(state) == "-" && State.peek(state, 2) == ">" ->
          state = State.consume(State.consume(state))
          {state, %Tokens.CDC{}}
        start_of_identifier?(state.grapheme, State.peek(state), State.peek(state, 2)) ->
          consume_identifier_or_function(State.reconsume(state))
        true ->
          {state, %Tokens.Delim{value: "-"}}
      end
    else
      {state, nil}
    end
  end
end
