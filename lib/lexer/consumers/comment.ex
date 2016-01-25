defmodule ExCss.Lexer.Consumers.Comment do
  import ExCss.Lexer.Shared
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state, 1) == "/" && State.peek(state, 2) == "*" do
      state
      |> State.consume
      |> State.consume
      |> consume_until_comment_closes
    else
      {state, nil}
    end
  end

  defp consume_until_comment_closes(state), do: consume_until_comment_closes(state, "")
  defp consume_until_comment_closes(state, content) do
    state = State.consume(state)

    cond do
      end_of_file?(state.grapheme) ->
        {state, {:error, {"comment wasn't closed before the end of the file"}}} #TODO: no returning error token?
      String.ends_with?(content <> state.grapheme, "*/") ->
        {state, %Tokens.Comment{value: String.slice(content, 0..-2)}}
      true ->
        consume_until_comment_closes(state, content <> state.grapheme)
    end
  end
end
