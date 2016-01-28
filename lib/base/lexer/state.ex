defmodule ExCss.Lexer.State do
  defstruct graphemes: {}, i: -1, grapheme: nil

  @t __MODULE__

  def new(str), do: new(str, -1)
  def new(str, i) do
    graphemes = preprocess(str)

    grapheme = if index_in_range?(graphemes, i) do
      elem(graphemes, i)
    else
      nil
    end

    %@t{
      graphemes: graphemes,
      i: i,
      grapheme: grapheme
    }
  end

  defp preprocess(str) do
    # TODO:
    # Replace any U+000D CARRIAGE RETURN (CR) code point, U+000C FORM FEED (FF) code point, or pairs of U+000D CARRIAGE RETURN (CR) followed by U+000A LINE FEED (LF) by a single U+000A LINE FEED (LF) code point.
    # Replace any U+0000 NULL code point with U+FFFD REPLACEMENT CHARACTER (�).
    List.to_tuple(String.graphemes(str))
  end

  defp index_in_range?(graphemes, index) do
    index >= 0 && index < tuple_size(graphemes)
  end

  def peek(state), do: peek(state, 1)
  def peek(state, index_delta) when index_delta <= 3 do
    new_i = state.i + index_delta
    if index_in_range?(state.graphemes, new_i) do
      elem(state.graphemes, new_i)
    else
      nil
    end
  end

  def consume(state) do
    %@t{state | i: state.i + 1, grapheme: peek(state)}
  end

  def reconsume(state) do
    %@t{state | i: state.i - 1, grapheme: peek(state, -1)}
  end
end
