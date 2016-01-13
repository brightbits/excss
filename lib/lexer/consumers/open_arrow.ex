defmodule ExCss.Lexer.Consumers.OpenArrow do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "<" do
      state = state |> consume

      if peek(state, 1) == "!" && peek(state, 2) == "-" && peek(state, 3) == "-" do
        state = state |> consume(3)
        {state, {:cdo, {}}}
      else
        {state, {:delim, {state.char}}}
      end
    else
      {state, nil}
    end
  end
end
