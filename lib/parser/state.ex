defmodule ExCss.Parser.State do
  defstruct tokens: {}, i: -1, token: nil

  @t __MODULE__

  def new(str) do
    %@t{tokens: ExCss.Lexer.do_it(str)}
  end

  def for_declaration(tokens) do
    %@t{tokens: tokens}
  end

  def currently?(state, type) do
    if state.token == nil do
      false
    else
      elem(state.token, 0) == type
    end
  end

  def not_currently?(state, type) do
    !currently?(state, type)
  end

  def token_type(state) do
     elem(state.token, 0)
  end

  def currently_simple_block?(state) do
    try do
      %ExCss.Parser.SimpleBlock{associated_token: {:open_curly, {}}} = state.token
      true
    rescue
      _ in MatchError -> false
    end
  end

  def token_mirror(state) do
    case token_type(state) do
      :open_curly -> :close_curly
      :open_parenthesis -> :close_parenthesis
      :open_square -> :close_square
      _ -> raise "unknown token mirror for #{inspect state.token}"
    end
  end

  def consume_ignoring_whitespace(state) do
    state = state |> consume

    if state |> currently?(:whitespace) do
      consume_ignoring_whitespace(state)
    else
      state
    end
  end

  def consume(state) do
    new_i = state.i + 1
    new_state = if new_i < tuple_size(state.tokens) do
      %@t{state | i: new_i, token: elem(state.tokens, new_i)}
    else
      %@t{state | token: {:eof, {}}}
    end
    IO.puts "CONS: #{inspect new_state.token}"
    new_state
  end

  def reconsume(state) do
    new_i = state.i - 1
    new_state = if new_i >= -1 do
      if new_i >= 0 do
        %@t{state | i: new_i, token: elem(state.tokens, new_i)}
      else
        %@t{state | i: new_i, token: nil}
      end
    else
      %@t{state | token: {:eof, {}}}
    end
    IO.puts "RECO: #{inspect new_state.token}"
    new_state
  end
end
