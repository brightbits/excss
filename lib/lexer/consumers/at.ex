defmodule ExCss.Lexer.Consumers.At do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "@" do
      state = state |> consume

      if start_of_identifier?(peek(state), peek(state), peek(state)) do
        {state, name} = consume_name(state)
        {state, {:at_keyword, {name}}}
      else
        {state, {:delim, {"@"}}}
      end
    else
      {state, nil}
    end
  end
end
