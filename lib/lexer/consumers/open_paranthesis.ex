defmodule ExCss.Lexer.Consumers.OpenParenthesis do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "(" do
      state = state |> consume
      {state, {:open_parenthesis, {}}}
    else
      {state, nil}
    end
  end
end
