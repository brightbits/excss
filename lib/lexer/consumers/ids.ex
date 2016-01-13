defmodule ExCss.Lexer.Consumers.Ids do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if name_start_char?(peek(state)) do
      consume_identifier_or_function(state)
    else
      {state, nil}
    end
  end
end
