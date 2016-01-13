defmodule ExCss.Lexer.Consumers.SubstringMatch do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "*" do
      state = state |> consume
      if peek(state) == "=" do
        state = state |> consume
        {state, {:substring_match, {}}}
      else
        {state, {:delim, {state.char}}}
      end
    else
      {state, nil}
    end
  end
end
