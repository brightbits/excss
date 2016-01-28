defmodule ExCss.Parser.Nodes.Function do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  defstruct name: nil, value: {}

  def pretty_print(function, indent) do
    PrettyPrint.pretty_out("Function:", indent)
    PrettyPrint.pretty_out("Name: #{function.name}", indent + 1)
    PrettyPrint.pretty_out("Value:", indent + 1)
    PrettyPrint.pretty_out(function.value, indent + 2)
  end

  def parse(state) do
    state |> State.debug("-- CONSUMING A FUNCTION --")

    state
    |> State.consume # step over the Function token
    |> consume_a_function(state.token.value)
  end

  defp consume_a_function(state, name) when is_binary(name) do
    {state, function} = consume_a_function(state, %N.Function{name: name, value: []})

    value =
      function.value
      |> Enum.reverse
      |> List.to_tuple

    {state, %{function | value: value}}
  end

  defp consume_a_function(state, function) when is_map(function) do
    # Create a function with a name equal to the value of the current input token, and with a value which is initially an empty list.
    #
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # <)-token>
    # Return the function.
    # anything else
    # Reconsume the current input token. Consume a component value and append the returned value to the function’s value.
    if State.currently?(state, [T.EndOfFile, T.CloseParenthesis]) do
      {State.consume(state), function}
    else
      {state, component_value} = State.consume_component_value(state)
      consume_a_function(state, %{function | value: [component_value] ++ function.value})
    end
  end
end
