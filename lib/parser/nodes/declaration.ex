defmodule ExCss.Parser.Nodes.Declaration do
  import ExCss.Utils.PrettyPrint
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Utils.Log
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  defstruct name: nil, value: [], important: false

  def pretty_print(_, indent) do
    pretty_out("Declaration", indent)
  end

  def parse(state) do
    consume_a_declaration(state)
  end

  defp consume_a_declaration(state) do
    Log.debug "-- CONSUMING A DECLARATION --"
    PrettyPrint.tokens(state.tokens)
    Log.debug "---"
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is anything other than a <colon-token>, this is a parse error. Return nothing.
    state = state |> State.consume_ignoring_whitespace

    name = state.token.value

    state = state |> State.consume_ignoring_whitespace

    if state |> State.not_currently?(Tokens.Colon) do
      {state, nil}
    else
      state = state |> State.consume_whitespace

      {state, declaration} = consume_a_declaration(state, %ExCss.Parser.Nodes.Declaration{name: name})

      declaration = %{declaration | value: Enum.reverse(declaration.value)}
      {state, declaration}
    end
  end
  defp consume_a_declaration(state, declaration) do
    # Otherwise, consume the next input token.
    #
    # While the current input token is anything other than an <EOF-token>,
    # append it to the declaration’s value and consume the next input token.
    {state, component_value} = state |> ExCss.Parser.consume_a_component_value

    if component_value != %Tokens.EndOfFile{} do
      declaration = %{declaration | value: [component_value] ++ declaration.value}
      consume_a_declaration(state, declaration)
    else
      {state, apply_declaration_importance(declaration)}
    end
  end

  defp apply_declaration_importance(declaration) do
    # If the last two non-<whitespace-token>s in the declaration’s value are a <delim-token> with the value "!" followed by an <ident-token> with a value that is an ASCII case-insensitive match for "important", remove them from the declaration’s value and set the declaration’s important flag to true.
    # Return the declaration.

    if length(declaration.value) > 2 do
      state = State.new(declaration.value) |> State.consume_ignoring_whitespace

      if State.currently?(state, Tokens.Id) && String.downcase(state.token.value) == "important" do
        state = state |> State.consume

        if state.token == %Tokens.Delim{value: "!"} do
          declaration = %{declaration | value: Enum.drop(declaration.value, state.i + 1), important: true}
        end
      end
      declaration
    else
      declaration
    end
  end
end
