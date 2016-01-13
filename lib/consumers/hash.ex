defmodule ExCss.Consumers.Hash do
  import ExCss.Consumer

  def accept(state) do

    if peek(state) == "#" do
      state = state |> consume

      if name_char?(peek(state)) || valid_escape_sequence?(peek(state), peek(state, 2)) do
        accept_hash_or_id(state)
      else
        {:delim, state.char}
      end
    else
      {state, nil}
    end
  end

  defp accept_hash_or_id(state) do
    {state, name} = accept_name(state)

	  token = if start_of_identifier?(String.at(name, 0), String.at(name, 1), String.at(name, 2)) do # fix this shity
      {:id, name}
    else
      {:hash, name}
	  end

    {state, token}
  end

  defp accept_name(state), do: accept_name(state, "")
  defp accept_name(state, content) do
    char = peek(state, 1)
    cond do
      name_char?(char) ->
        state = state |> consume
        accept_name(state, content <> state.char)
      valid_escape_sequence?(char, peek(state, 2)) ->
        state = state |> consume
        accept_name(state, content) # <> consume_escaped_char)
    end
  end
end
