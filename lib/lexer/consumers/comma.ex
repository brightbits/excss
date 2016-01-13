defmodule ExCss.Lexer.Consumers.Comma do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "," do
      state = state |> consume
      {state, {:comma, {}}}
    else
      {state, nil}
    end
  end
end
