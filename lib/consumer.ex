defmodule ExCss.Consumer do
  def peek(state), do: peek(state, 1)
  def peek(%{str: str, pos: pos}, character_number) when character_number <= 2 do
    str |> String.at(pos + character_number)
  end

  def consume(state, 0), do: state
  def consume(state, count), do: consume(consume(state), count - 1)
  def consume(state = %{pos: pos}) do
    Map.merge(state, %{pos: pos + 1, char: peek(state)})
  end

  def reconsume(state = %{pos: pos}) do
    Map.merge(state, %{pos: pos - 1, char: peek(state, -2)})
  end

  def add_warning(state = %{warnings: warnings}, message) do
    Map.merge(state, %{warnings: warnings ++ [message]})
  end

  def end_of_file?(nil), do: true
  def end_of_file?(_), do: false

  def whitespace?(char), do: new_line?(char) || char == "\t" || char == " "

  def new_line?(char), do: char == "\n"

  defp code_of(char) do
    << code :: utf8 >> = char
    code
  end

  def between?(nil, _, _), do: false
  def between?(char, first_char, second_char) do
    char_code = code_of(char)
    char_code >= code_of(first_char) && char_code <= code_of(second_char)
  end

  def valid_escape_sequence?(first_char, second_char) do
    first_char == "\\" && !new_line?(second_char)
  end

  def start_of_identifier?(first_char, second_char, third_char) do
    cond do
      first_char == "-" ->
        name_start_char?(second_char) || second_char == "c2" || valid_escape_sequence?(second_char, third_char)
      name_start_char?(first_char) ->
        true
      first_char == "\\" ->
        valid_escape_sequence?(first_char, second_char)
      true -> false
    end
  end

  # assume peeked char is \
  def consume_escaped_char(state) do
    state = state |> consume

    char = peek(state)

    cond do
      hex_digit?(char) ->
        consume_hex_number(state)
      end_of_file?(char) ->
        {consume(state), <<65533>>}
      true ->
        {consume(state), char}
    end
  end

  defp consume_hex_number(state) do
    {new_state, content} = consume_hex_number(state, "", 0)
    padded_content = String.rjust(content, 6, ?0)
    stripped_content = String.replace(padded_content, ~r{00}, "")
    char = Base.decode16!(stripped_content, case: :mixed)
    {new_state, char}
  end

  defp consume_hex_number(state, content, count) do
    char = peek(state)
    if hex_digit?(char) do
      state = state |> consume
      content = content <> char

      if count < 5 do
        state |> consume_hex_number(content, count + 1)
      else
        {state, content}
      end
    else
      {state, content}
    end
  end

  def digit?(code), do: between?(code, "0", "9")
  def hex_digit?(code), do: digit?(code) || between?(code, "A", "F") || between?(code, "a", "f")
  def uppercase_letter?(code), do: between?(code, "A", "Z")
  def lowercase_letter?(code), do: between?(code, "a", "z")
  def letter?(code), do: uppercase_letter?(code) || lowercase_letter?(code)
  def non_ascii?(code), do: code >= <<128>>
  def name_start_char?(code), do: letter?(code) || non_ascii?(code) || code == "_"
  def name_char?(code), do: name_start_char?(code) || digit?(code) || code == "-"
end
