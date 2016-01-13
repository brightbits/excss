defmodule ExCss.Lexer.Consumers.Minus do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "-" do
      state = state |> consume

      cond do
        start_of_number?(state.char, peek(state), peek(state, 2)) ->
          consume_numeric(state |> reconsume)
        peek(state) == "-" && peek(state, 2) == ">" ->
          state = state |> consume(2)
          {state, {:cdc, {}}}
        true ->
          {state, {:delim, {"-"}}}
      end
    else
      {state, nil}
    end
  end
end
