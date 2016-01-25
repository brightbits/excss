defmodule ExCss.Lexer.Consumers.OpenArrow do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "<" do
      state = State.consume(state)

      if State.peek(state, 1) == "!" && State.peek(state, 2) == "-" && State.peek(state, 3) == "-" do
        state = State.consume(State.consume(State.consume(state)))
        {state, %Tokens.CDO{}}
      else
        {state, %Tokens.Delim{value: state.grapheme}}
      end
    else
      {state, nil}
    end
  end
end
