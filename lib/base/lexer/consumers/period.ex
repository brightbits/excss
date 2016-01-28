defmodule ExCss.Lexer.Consumers.Period do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "." do
      state = State.consume(state)

      if start_of_number?(state.grapheme, State.peek(state), State.peek(state, 2)) do
        consume_numeric(State.reconsume(state))
      else
        {state, %Tokens.Delim{value: "."}}
      end
    else
      {state, nil}
    end
  end
end
