defmodule ExCss.Parser.Nodes.Function do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Utils.Log
  alias ExCss.Parser
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  defstruct name: nil, value: []

  def pretty_print(_, indent) do
    PrettyPrint.pretty_out("Function", indent)
  end

  def to_pretty(function), do: "<FUNCTION #{function.name} value: #{inspect function.value}>"

  def parse(state) do
    consume_a_function(state)
  end

  defp consume_a_function(state) do
    Log.debug "-- CONSUMING A FUNCTION --"
    name = state.token.value
    state = state |> State.consume
    consume_a_function(state, %ExCss.Parser.Nodes.Function{name: name, value: []})
  end
  defp consume_a_function(state, function) do
    # Create a function with a name equal to the value of the current input token, and with a value which is initially an empty list.
    #
    # Repeatedly consume the next input token and process it as follows:
    #
    # <EOF-token>
    # <)-token>
    # Return the function.
    # anything else
    # Reconsume the current input token. Consume a component value and append the returned value to the function’s value.
    state = state |> State.consume

    if State.currently?(state, [Tokens.EndOfFile, Tokens.CloseParenthesis]) do
      {state, function}
    else
      {state, component_value} = state |> State.reconsume |> Parser.consume_a_component_value
      consume_a_function(state, %{function | value: function.value ++ [component_value]})
    end
  end
end
