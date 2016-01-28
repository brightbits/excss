defmodule ExCss.Lexer.Consumers.String do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    char = State.peek(state)
    if char == "\"" || char == "'" do
      state
      |> State.consume
      |> consume_until_string_closes(char)
    else
      {state, nil}
    end
  end

  defp consume_until_string_closes(state, closing_char), do: consume_until_string_closes(state, closing_char, "")
  defp consume_until_string_closes(state, closing_char, content) do
    state = State.consume(state)

    cond do
      end_of_file?(state.grapheme) || state.grapheme == closing_char ->
        {state, %Tokens.String{value: content, wrapped_by: closing_char}}
      new_line?(state.grapheme) ->
        state = State.reconsume(state) #|> add_warning("String wasn't closed before new line and the new line wasn't escaped")
        {state, %Tokens.BadString{}}
      state.grapheme == "\\" ->
        {state, char} = state |> consume_escape
        state = state
        |> consume_until_string_closes(closing_char, content <> char)
      true ->
        state
        |> consume_until_string_closes(closing_char, content <> state.grapheme)
    end
  end

  defp consume_escape(state) do
    cond do
      end_of_file?(State.peek(state)) ->
        {state, ""}
      new_line?(State.peek(state)) ->
        {State.consume(state), ""}
      true ->
        state
        |> State.reconsume
        |> consume_escaped_char
    end
  end
end
