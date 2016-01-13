defmodule ExCss.Lexer.Consumers.CloseCurly do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "}" do
      state = state |> consume
      {state, {:close_curly, {}}}
    else
      {state, nil}
    end
  end
end
