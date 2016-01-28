defmodule ExCss.Lexer.Consumers.LiteralEscape do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.State

  def accept(state) do
    char = State.peek(state)
    if char == "\\" do
      if valid_escape_sequence?(char, State.peek(state, 2)) do
        state
        |> consume_identifier_or_function
      else
        state = State.consume(state)
        #|> add_warning("Invalid escape sequence")

        {state, nil}
      end
    else
      {state, nil}
    end
  end
end
