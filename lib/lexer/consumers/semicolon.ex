defmodule ExCss.Lexer.Consumers.Semicolon do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == ";" do
      state = state |> consume
      {state, {:semicolon, {}}}
    else
      {state, nil}
    end
  end
end
