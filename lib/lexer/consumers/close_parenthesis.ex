defmodule ExCss.Lexer.Consumers.CloseParenthesis do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == ")" do
      state = state |> consume
      {state, {:close_parenthesis, {}}}
    else
      {state, nil}
    end
  end
end
