defmodule ExCss.Lexer.Consumers.Hash do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state) == "#" do
      state = state |> consume

      if name_char?(peek(state)) || valid_escape_sequence?(peek(state), peek(state, 2)) do
        accept_hash_or_id(state)
      else
        {state, {:delim, {state.char}}}
      end
    else
      {state, nil}
    end
  end

  defp accept_hash_or_id(state) do
    {state, name} = consume_name(state)

	  token = if start_of_identifier?(String.at(name, 0), String.at(name, 1), String.at(name, 2)) do # fix this shity
      {:hash, {name}}
    else
      {:hash, {name}}
	  end

    {state, token}
  end
end
