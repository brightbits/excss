defmodule ExCss.Lexer.Shared do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

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
    if whitespace?(State.peek(state)) do
      consume_whitespace(State.consume(state))
    else
      state
    end
  end

  def consume_name(state), do: consume_name(state, "")
  def consume_name(state, content) do
    char = State.peek(state, 1)
    cond do
      name_char?(char) ->
        state = State.consume(state)
        consume_name(state, content <> state.grapheme)
      valid_escape_sequence?(char, State.peek(state, 2)) ->
        {state, escape_char} = state
        |> consume_escaped_char

        consume_name(state, content <> escape_char)
      true ->
        {state, content}
    end
  end

  def consume_identifier_or_function(state) do
    {state, name} = state |> consume_name
    if String.downcase(name) == "url" && State.peek(state) == "(" do
      state = state
      |> State.consume
      |> consume_whitespace

      if State.peek(state) == "'" || State.peek(state) == "\"" do
        {state, %Tokens.Function{value: name}}
      else
        consume_url(state)
      end
    else
      if State.peek(state) == "(" do
        state = State.consume(state)
        {state, %Tokens.Function{value: name}}
      else
        {state, %Tokens.Id{value: name}}
      end
    end
  end

  def consume_url(state) do
    state = consume_whitespace(state)
    consume_url(state, "")
  end

  defp consume_url(state, content) do
    state = State.consume(state)
    cond do
      state.grapheme == ")" || end_of_file?(state.grapheme) ->
        {state, %Tokens.Url{value: content}}

      whitespace?(state.grapheme) ->
        state = state
        |> consume_whitespace
        |> State.consume

        if state.grapheme == ")" || end_of_file?(state.grapheme) do
          {state, %Tokens.Url{value: content}}
        else
          state = state |> consume_remnants_of_bad_url
          {state, %Tokens.BadUrl{}}
        end

      state.grapheme == "\"" || state.grapheme == "'" || state.grapheme == "(" || non_printable?(state.grapheme) ->
        state = state # |> add_warning("Bad url encountered")
        |> consume_remnants_of_bad_url
        {state, %Tokens.BadUrl{}}
      state.grapheme == "\\" ->
        if valid_escape_sequence?(state.grapheme, State.peek(state)) do
          {state, escaped_char} = consume_escaped_char(state)
          consume_url(state, content <> escaped_char)
        else
          state = state # |> add_warning("Bad escape encountered in a url")
          |> consume_remnants_of_bad_url
          {state, %Tokens.BadUrl{}}
        end

      true ->
        consume_url(state, content <> state.grapheme)
    end
  end

  defp consume_remnants_of_bad_url(state) do
    state = State.consume(state)
    cond do
      state.grapheme == "-" || end_of_file?(state.grapheme) ->
        state
      valid_escape_sequence?(state.grapheme, State.peek(state)) ->
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
      start_of_identifier?(State.peek(state, 1), State.peek(state, 2), State.peek(state, 3)) ->
        {state, dimension} = consume_name(state)
        {state, %Tokens.Dimension{value: number, original_value: number_string, unit: dimension}}
      State.peek(state, 1) == "%" ->
        state = State.consume(state)
        {state, %Tokens.Percentage{value: number, original_value: number_string}}
      true ->
        {state, %Tokens.Number{value: number, original_value: number_string}}
    end
  end

  def consume_number(state) do
    result = ""

    if plus_or_minus?(State.peek(state)) do
      state = State.consume(state)
      result = result <> state.grapheme
    end

    {state, digits} = consume_some_digits(state)
    result = result <> digits

    if State.peek(state) == "." && digit?(State.peek(state, 2)) do
       state = State.consume(state)
       result = result <> state.grapheme # .

       {state, digits} = consume_some_digits(state)
       result = result <> digits
    end

    if (State.peek(state) == "e" || State.peek(state) == "E") && (digit?(State.peek(state, 2)) || plus_or_minus?(State.peek(state, 2))) do
      state = State.consume(state)
      result = result <> state.grapheme # e/E

      cond do
        plus_or_minus?(State.peek(state)) && digit?(State.peek(state, 2)) ->
          state = State.consume(state)
          result = result <> state.grapheme # +/-

          {state, digits} = consume_some_digits(state)
          result = result <> digits

        digit?(State.peek(state)) ->
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
    if digit?(State.peek(state)) do
      state = State.consume(state)
      consume_some_digits(state, content <> state.grapheme)
    else
      {state, content}
    end
  end

  # assume peeked char is \
  def consume_escaped_char(state) do
    state = State.consume(state)

    char = State.peek(state)

    cond do
      hex_digit?(char) ->
        consume_hex_number(state)
      end_of_file?(char) ->
        {State.consume(state), <<65533>>}
      true ->
        {State.consume(state), char}
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
    char = State.peek(state)
    if hex_digit?(char) do
      state = State.consume(state)
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

  def digit?(grapheme), do: between?(grapheme, "0", "9")
  def hex_digit?(grapheme), do: digit?(grapheme) || between?(grapheme, "A", "F") || between?(grapheme, "a", "f")
  def uppercase_letter?(grapheme), do: between?(grapheme, "A", "Z")
  def lowercase_letter?(grapheme), do: between?(grapheme, "a", "z")
  def letter?(grapheme), do: uppercase_letter?(grapheme) || lowercase_letter?(grapheme)
  def non_ascii?(grapheme), do: grapheme >= <<128>>
  def name_start_char?(grapheme), do: letter?(grapheme) || non_ascii?(grapheme) || grapheme == "_"
  def name_char?(grapheme), do: name_start_char?(grapheme) || digit?(grapheme) || grapheme == "-"
  def non_printable?(grapheme), do: between?(grapheme, <<0>>, <<8>>) || grapheme == <<0xb>> || between?(grapheme, <<0xe>>, <<0x1f>>) || grapheme == <<0x7f>>
  def plus_or_minus?(grapheme), do: grapheme == "-" || grapheme == "+"
end
