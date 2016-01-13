defmodule ExCss.Lexer.Consumer do
  def peek(state), do: peek(state, 1)
  def peek(%{str: str, pos: pos}, character_number) when character_number <= 3 do
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
        name_start_char?(second_char) || second_char == "-" || valid_escape_sequence?(second_char, third_char)
      name_start_char?(first_char) ->
        true
      first_char == "\\" ->
        valid_escape_sequence?(first_char, second_char)
      true -> false
    end
  end

  def consume_whitespace(state) do
    if whitespace?(peek(state)) do
      consume_whitespace(state |> consume)
    else
      state
    end
  end

  def consume_name(state), do: consume_name(state, "")
  def consume_name(state, content) do
    char = peek(state, 1)
    cond do
      name_char?(char) ->
        state = state |> consume
        consume_name(state, content <> state.char)
      valid_escape_sequence?(char, peek(state, 2)) ->
        {state, escape_char} = state
        |> consume_escaped_char

        consume_name(state, content <> escape_char)
      true ->
        {state, content}
    end
  end

  def consume_identifier_or_function(state) do
    {state, name} = state |> consume_name
    if String.downcase(name) == "url" && peek(state) == "(" do
      state = state |> consume |> consume_whitespace
      if peek(state) == "'" || peek(state) == "\"" do
        {state, {:function, {name}}}
      else
        state |> consume_url
      end
    else
      if peek(state) == "(" do
        state = state |> consume
        {state, {:function, {name}}}
      else
        {state, {:id, {name}}}
      end
    end
  end

  def consume_url(state) do
    state = state |> consume_whitespace
    consume_url(state, "")
  end

  defp consume_url(state, content) do
    state = state |> consume
    cond do
      state.char == ")" || end_of_file?(state.char) ->
        {state, {:url, {content}}}

      whitespace?(state.char) ->
        state = state
        |> consume_whitespace
        |> consume

        if state.char == ")" || end_of_file?(state.char) do
          {state, {:url, {content}}}
        else
          state = state |> consume_remnants_of_bad_url
          {state, {:bad_url, {}}}
        end

      state.char == "\"" || state.char == "'" || state.char == "(" || non_printable?(state.char) ->
        state = state
        |> add_warning("Bad url encountered")
        |> consume_remnants_of_bad_url
        {state, {:bad_url, {}}}
      state.char == "\\" ->
        if valid_escape_sequence?(state.char, peek(state)) do
          {state, escaped_char} = consume_escaped_char(state)
          consume_url(state, content <> escaped_char)
        else
          state = state
          |> add_warning("Bad escape encountered in a url")
          |> consume_remnants_of_bad_url
          {state, {:bad_url, {}}}
        end

      true ->
        consume_url(state, content <> state.char)
    end
  end

  defp consume_remnants_of_bad_url(state) do
    state = state |> consume
    cond do
      state.char == "-" || end_of_file?(state.char) ->
        state
      valid_escape_sequence?(state.char, peek(state)) ->
        {state, escape_char} = state
        |> consume_escaped_char
        consume_remnants_of_bad_url(state)
      true ->
        consume_remnants_of_bad_url(state)
    end
  end

  def start_of_number?(first_char, second_char, third_char) do
    cond do
      first_char == "-" || first_char == "+" ->
        digit?(second_char) || (second_char == "." && digit?(third_char))
      first_char == "." && digit?(second_char) ->
        true
      digit?(first_char) ->
        true
      true -> false
    end
	end

  def consume_numeric(state) do
    {state, {number, number_string}} = consume_number(state)

    cond do
      start_of_identifier?(peek(state, 1), peek(state, 2), peek(state, 3)) ->
        {state, dimension} = consume_name(state)
        {state, {:dimension, {number, number_string, dimension}}}
      peek(state, 1) == "%" ->
        state = consume(state)
        {state, {:percentage, {number, number_string}}}
      true ->
        {state, {:number, {number, number_string}}}
    end
  end

  def consume_number(state) do
    result = ""

    if plus_or_minus?(peek(state)) do
      state = state |> consume
      result = result <> state.char
    end

    {state, digits} = consume_some_digits(state)
    result = result <> digits

    if peek(state) == "." && digit?(peek(state, 2)) do
       state = state |> consume
       result = result <> state.char # .

       {state, digits} = consume_some_digits(state)
       result = result <> digits
    end

    if (peek(state) == "e" || peek(state) == "E") && (digit?(peek(state, 2)) || plus_or_minus?(peek(state, 2))) do
      state = state |> consume
      result = result <> state.char # e/E

      cond do
        plus_or_minus?(peek(state)) && digit?(peek(state, 2)) ->
          state = state |> consume
          result = result <> state.char # +/-

          {state, digits} = consume_some_digits(state)
          result = result <> digits

        digit?(peek(state)) ->
          {state, digits} = consume_some_digits(state)
          result = result <> digits

        true ->
          nil
      end
    end

    {number, ""} = if String.starts_with?(result, ".") do
      Float.parse("0" <> result)
    else
      Float.parse(result)
    end

    {state, {number, result}}
  end

  defp consume_some_digits(state), do: consume_some_digits(state, "")
  defp consume_some_digits(state, content) do
    if digit?(peek(state)) do
      state = state |> consume
      consume_some_digits(state, content <> state.char)
    else
      {state, content}
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

  def digit?(char), do: between?(char, "0", "9")
  def hex_digit?(char), do: digit?(char) || between?(char, "A", "F") || between?(char, "a", "f")
  def uppercase_letter?(char), do: between?(char, "A", "Z")
  def lowercase_letter?(char), do: between?(char, "a", "z")
  def letter?(char), do: uppercase_letter?(char) || lowercase_letter?(char)
  def non_ascii?(char), do: char >= <<128>>
  def name_start_char?(char), do: letter?(char) || non_ascii?(char) || char == "_"
  def name_char?(char), do: name_start_char?(char) || digit?(char) || char == "-"
  def non_printable?(char), do: between?(char, <<0>>, <<8>>) || char == <<0xb>> || between?(char, <<0xe>>, <<0x1f>>) || char == <<0x7f>>
  def plus_or_minus?(char), do: char == "-" || char == "+"
end
