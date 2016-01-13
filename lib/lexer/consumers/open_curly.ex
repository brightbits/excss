defmodule ExCss.Lexer.Consumers.OpenCurly do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "{" do
      state = state |> consume
      {state, {:open_curly, {}}}
    else
      {state, nil}
    end
  end
end
