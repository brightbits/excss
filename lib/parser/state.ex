defmodule ExCss.Parser.State do
  defstruct tokens: {}, i: -1, token: nil
  @t __MODULE__

  alias ExCss.Lexer.Token
  alias ExCss.Lexer.Tokens
  alias ExCss.Utils.Log

  def new(str) when is_binary(str) do
    %@t{tokens: ExCss.Lexer.lex(str)}
  end

  def new(tokens) when is_tuple(tokens) do
    %@t{tokens: tokens}
  end

  def new(tokens) when is_list(tokens) do
    %@t{tokens: List.to_tuple(tokens)}
  end

  def debug(state) do
    IO.puts " DEBUG OF STATE "
    for i <- Enum.to_list(0..5) do
      IO.puts Token.to_pretty(elem(state.tokens, state.i + i))
    end
  end

  def currently?(state, types) when is_list(types) do
    types
    |> Enum.map(fn (type) -> currently?(state, type) end)
    |> Enum.any?
  end
  def currently?(state, type) when is_atom(type) do
    if state.token == nil do
      false
    else
      Token.type(state.token) == type
    end
  end

  def not_currently?(state, type) do
    !currently?(state, type)
  end

  def currently_simple_block?(state) do
    try do
      %ExCss.Parser.Nodes.SimpleBlock{associated_token: %Tokens.OpenCurly{}} = state.token
      true
    rescue
      _ in MatchError -> false
    end
  end

  def token_mirror(state) do
    case Token.type(state.token) do
      Tokens.OpenCurly -> Tokens.CloseCurly
      Tokens.OpenParenthesis -> Tokens.CloseParenthesis
      Tokens.OpenSquare -> Tokens.CloseSquare
      _ -> raise "unknown token mirror for #{inspect state.token}"
    end
  end

  def consume_ignoring_whitespace(state) do
    state = state |> consume

    if state |> currently?(Tokens.Whitespace) do
      consume_ignoring_whitespace(state)
    else
      state
    end
  end

  def consume_whitespace(state) do
    state = state |> consume
    if state |> currently?(Tokens.Whitespace) do
      state
    else
      state |> reconsume
    end
  end

  def consume(state) do
    new_i = state.i + 1
    new_state = if new_i < tuple_size(state.tokens) do
      %@t{state | i: new_i, token: elem(state.tokens, new_i)}
    else
      %@t{state | token: %Tokens.EndOfFile{}}
    end
    Log.debug "CONS: #{Token.to_pretty(new_state.token)}"
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
      %@t{state | token: %Tokens.EndOfFile{}}
    end
    #Log.debug "RECO: #{inspect new_state.token}"
    new_state
  end
end
