defmodule ExCss.Consumers.String do
  import ExCss.Consumer

  def accept(state) do
    char = peek(state)
    if char == "\"" || char == "'" do
      state
      |> consume
      |> consume_until_string_closes(char)
    else
      {state, nil}
    end
  end

  defp consume_until_string_closes(state, closing_char), do: consume_until_string_closes(state, closing_char, "")
  defp consume_until_string_closes(state, closing_char, content) do
    state = state |> consume

    cond do
      end_of_file?(state.char) || state.char == closing_char ->
        {state, {:string, content}}
      new_line?(state.char) ->
        state = state
        |> add_warning("String wasn't closed before new line and the new line wasn't escaped")
        |> reconsume
        {state, {:bad_string, content}}
      state.char == "\\" ->
        {state, char} = state |> consume_escape
        state = state
        |> consume_until_string_closes(closing_char, content <> char)
      true ->
        state
        |> consume_until_string_closes(closing_char, content <> state.char)
    end
  end

  defp consume_escape(state) do
    cond do
      end_of_file?(peek(state)) ->
        {state, ""}
      new_line?(peek(state)) ->
        {state |> consume, ""}
      true ->
        state 
        |> reconsume
        |> consume_escaped_char
    end
  end
end
