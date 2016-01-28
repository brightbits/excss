defmodule ExCss.Lexer.Consumers.Ids do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.State

  def accept(state) do
    if name_start_char?(State.peek(state)) do
      consume_identifier_or_function(state)
    else
      {state, nil}
    end
  end
end
