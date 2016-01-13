defmodule ExCss.Lexer.Consumers.Colon do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == ":" do
      state = state |> consume
      {state, {:colon, {}}}
    else
      {state, nil}
    end
  end
end
