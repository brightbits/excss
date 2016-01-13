defmodule ExCss.Lexer.Consumers.LiteralEscape do
  import ExCss.Lexer.Consumer

  def accept(state) do
    char = peek(state)
    if char == "\\" do
      if valid_escape_sequence?(char, peek(state, 2)) do
        state
        |> consume_identifier_or_function
      else
        state = state
        |> consume(1)
        |> add_warning("Invalid escape sequence")

        {state, nil}
      end
    else
      {state, nil}
    end
  end
end
