defmodule ExCss.Lexer.Consumers.Whitespace do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if whitespace?(peek(state)) do
      {consume_until_not_whitespace(state), {:whitespace, {}}}
    else
      {state, nil}
    end
  end

  defp consume_until_not_whitespace(state) do
    if whitespace?(peek(state)) do
      state
      |> consume
      |> consume_until_not_whitespace
    else
      state
    end
  end
end
