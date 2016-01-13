defmodule ExCss.Lexer.Consumers.DashMatch do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "|" do
      state = state |> consume
      cond do
        peek(state) == "=" ->
          {state |> consume, {:dash_match, {}}}
        peek(state) == "|" ->
          {state |> consume, {:column, {}}}
        true ->
          {state, {:delim, {"|"}}}
      end
    else
      {state, nil}
    end
  end
end
