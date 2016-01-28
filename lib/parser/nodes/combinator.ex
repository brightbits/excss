defmodule ExCss.Parser.Nodes.Combinator do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct type: nil, left: nil, right: nil

  def pretty_print(combinator, indent) do
    PrettyPrint.pretty_out("Combinator #{combinator.type}", indent)
    PrettyPrint.pretty_out("Left:", indent + 1)
    PrettyPrint.pretty_out(combinator.left, indent + 2)
    PrettyPrint.pretty_out("Right:", indent + 1)
    PrettyPrint.pretty_out(combinator.right, indent + 2)
  end

  # combinator
  # /* combinators can be surrounded by whitespace */
  # : PLUS S* | GREATER S* | TILDE S* | S+
  # ;
  def parse(state) do
    consume_a_combinator(state)
  end

  defp consume_a_combinator(state, try_again \\ true) do
    state |> State.debug("-- CONSUMING A COMBINATOR --")

    combinator = cond do
      State.currently?(state, T.Delim, "+") -> # PLUS
        %N.Combinator{type: :adjacent_sibling}
      State.currently?(state, T.Delim, ">") -> # GREATER
        %N.Combinator{type: :child}
      State.currently?(state, T.Delim, "~") -> # TILDE
        %N.Combinator{type: :general_sibling}
      State.currently?(state, T.Whitespace) -> # S
        %N.Combinator{type: :descendant}
      true ->
        nil
    end

    if combinator do
      state =
        state
        |> State.consume # PLUS | GREATER | TILDE | S
        |> State.consume_whitespace # */+
    end

    # If its a whitespace combinator, consume another one,
    # if its still a combinator, return that one with the new state
    if try_again && combinator && combinator.type == :descendant do
      {new_state, new_combinator} = consume_a_combinator(state, false)
      if new_combinator do
        {new_state, new_combinator}
      else
        {state, combinator}
      end
    else
      {state, combinator}
    end
  end
end
