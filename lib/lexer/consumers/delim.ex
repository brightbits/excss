defmodule ExCss.Lexer.Consumers.Delim do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if end_of_file?(peek(state)) do
      {state, {:eof, {}}}
    else
      state = state |> consume
      {state, {:delim, {state.char}}}
    end
  end
end
