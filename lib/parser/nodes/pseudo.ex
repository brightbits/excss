defmodule ExCss.Parser.Nodes.Pseudo do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes
  alias ExCss.Lexer.Tokens
  defstruct value: nil, type: nil, function: nil

  def pretty_print(pseudo, indent) do
    PrettyPrint.pretty_out("Pseudo:", indent)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(pseudo.value, indent + 2)
    PrettyPrint.pretty_out("Type:", indent + 1)
    PrettyPrint.pretty_out(pseudo.type, indent + 2)
    PrettyPrint.pretty_out("Function:", indent + 1)
    PrettyPrint.pretty_out(pseudo.function, indent + 2)
  end

  # pseudo
  #   /* '::' starts a pseudo-element, ':' a pseudo-class */
  #   /* Exceptions: :first-line, :first-letter, :before and :after. */
  #   /* Note that pseudo-elements are restricted to one per selector and */
  #   /* occur only in the last simple_selector_sequence. */
  #   : ':' ':'? [ IDENT | functional_pseudo ]
  #   ;
  #
  # functional_pseudo
  #   : FUNCTION S* expression ')'
  #   ;
  #
  # expression
  #   /* In CSS3, the expressions are identifiers, strings, */
  #   /* or of the form "an+b" */
  #   : [ [ PLUS | '-' | DIMENSION | NUMBER | STRING | IDENT ] S* ]+
  #   ;
  def parse(state) do
    state |> State.debug("-- CONSUMING A PSEUDO --")
    state = State.consume(state) # :

    pseudo = %Nodes.Pseudo{type: :class}

    State.debug(state, "Currently: #{inspect state.token}")

    if State.currently?(state, Tokens.Colon) do
      State.debug(state, "Got another colon, now: #{inspect state.token}")
      state = State.consume(state) # :?
      pseudo = %{pseudo | type: :element} # |
    end

    if State.currently?(state, [Tokens.Id, Tokens.Function]) do
      State.debug(state, "Id or function, now: #{inspect state.token}")
      pseudo = %{pseudo | value: state.token.value} # |

      if State.currently?(state, Tokens.Function) do # functional_pseudo
        State.debug(state, "In the function: #{state.token.value}")
        {state, expression} =
          state
          |> State.consume # FUNCTION
          |> State.consume_whitespace # S*
          |> consume_expression # expression

        if expression && State.currently?(state, Tokens.CloseParenthesis) do # )
          {State.consume(state), %{pseudo | type: :function, function: expression}} # |
        else
          {state, nil}
        end
      else
        {State.consume(state), pseudo} # IDENT
      end
    else
      {state, nil}
    end
  end

  defp consume_expression(state) do
    {state, components} = consume_expression(state, [])

    if components do
      components =
        components
        |> Enum.reverse
        |> List.to_tuple
    end
    
    {state, components}
  end

  defp consume_expression(state, components) do # [
    State.debug(state, "In an expression, currently: #{inspect state.token}")
    {state, component} = consume_an_expression_component(state) # [ PLUS | '-' | DIMENSION | NUMBER | STRING | IDENT ]
    if component do
      State.debug(state, "Got component #{inspect component}, adding to #{inspect components}")
      components = [component] ++ components
      state = State.consume_whitespace(state) # S*
      # ]
      {new_state, more_components} = consume_expression(state, components) # +

      if more_components do
        {new_state, more_components}
      else
        {state, components}
      end
    else
      {state, nil}
    end
  end

  defp consume_an_expression_component(state) do
    if State.currently?(state, Tokens.Delim, "+") || State.currently?(state, Tokens.Delim, "-") || State.currently?(state, [Tokens.Whitespace, Tokens.Dimension, Tokens.Number, Tokens.String, Tokens.Id]) do
      {State.consume(state), state.token}
    else
      {state, nil}
    end
  end
end
