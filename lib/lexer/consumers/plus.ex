defmodule ExCss.Lexer.Consumers.Plus do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "+" do
      state = state |> consume

      if start_of_number?(state.char, peek(state), peek(state, 2)) do
        consume_numeric(state |> reconsume)
      else
        {state, {:delim, {"+"}}}
      end
    else
      {state, nil}
    end
  end
end
