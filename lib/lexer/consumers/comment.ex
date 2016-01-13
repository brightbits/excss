defmodule ExCss.Lexer.Consumers.Comment do
  import ExCss.Lexer.Consumer

  def accept(state) do
    if peek(state, 1) == "/" && peek(state, 2) == "*" do
      state
      |> consume(2)
      |> consume_until_comment_closes
    else
      {state, nil}
    end
  end

  defp consume_until_comment_closes(state), do: consume_until_comment_closes(state, "")
  defp consume_until_comment_closes(state, content) do
    state = state |> consume

    cond do
      end_of_file?(state.char) ->
        {state, {:error, {"comment wasn't closed before the end of the file"}}}
      String.ends_with?(content <> state.char, "*/") ->
        {state, {:comment, {String.slice(content, 0..-2)}}}
      true ->
        consume_until_comment_closes(state, content <> state.char)
    end
  end
end
