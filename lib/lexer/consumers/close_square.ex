defmodule ExCss.Lexer.Consumers.CloseSquare do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "]" do
      state = state |> consume
      {state, {:close_square, {}}}
    else
      {state, nil}
    end
  end
end
