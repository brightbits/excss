defmodule ExCss.Lexer.Consumers.Digits do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if digit?(peek(state)) do
      consume_numeric(state)
    else
      {state, nil}
    end
  end
end
