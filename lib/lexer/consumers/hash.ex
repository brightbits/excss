defmodule ExCss.Lexer.Consumers.Hash do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "#" do
      state = State.consume(state)

      if name_char?(State.peek(state)) || valid_escape_sequence?(State.peek(state), State.peek(state, 2)) do
        accept_hash_or_id(state)
      else
        {state, %Tokens.Delim{value: state.grapheme}}
      end
    else
      {state, nil}
    end
  end

  defp accept_hash_or_id(state) do
    {state, name} = consume_name(state)

    token = if start_of_identifier?(String.at(name, 0), String.at(name, 1), String.at(name, 2)) do # fix this shity
      %Tokens.Hash{value: name, id: true}
    else
      %Tokens.Hash{value: name, id: false}
    end

    {state, token}
  end
end
