defmodule ExCss.Lexer.Consumers.OpenSquare do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "[" do
      state = state |> consume
      {state, {:open_square, {}}}
    else
      {state, nil}
    end
  end
end
