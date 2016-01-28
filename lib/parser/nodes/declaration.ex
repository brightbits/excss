defmodule ExCss.Parser.Nodes.Declaration do
  alias ExCss.Utils.PrettyPrint
  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens
  defstruct name: nil, value: {}, important: false

  def pretty_print(declaration, indent) do
    PrettyPrint.pretty_out("Declaration:", indent)
    PrettyPrint.pretty_out("Name: #{declaration.name}", indent + 1)
    if declaration.important do
      PrettyPrint.pretty_out("Important", indent + 1)
    end

    PrettyPrint.pretty_out("Value:", indent + 1)

    for token <- Tuple.to_list(declaration.value) do
      PrettyPrint.pretty_out(token, indent + 2)
    end
  end

  def parse(state) do
    consume_a_declaration(state)
  end

  defp consume_a_declaration(state) do
    state |> State.debug("-- CONSUMING A DECLARATION --")
    # Consume the next input token.
    # While the current input token is a <whitespace-token>, consume the next input token.
    # If the current input token is anything other than a <colon-token>, this is a parse error. Return nothing.
    State.debug(state, "currently: #{inspect state.token}, using this for the name")

    name = state.token.value

    state =
      state
      |> State.consume # step past the name
      |> State.consume_whitespace # if current token is whitespace, step past it

    State.debug(state, "currently: #{inspect state.token}, expecting a colon")

    if state |> State.not_currently?(Tokens.Colon) do
      {state, nil}
    else
      state =
        state
        |> State.consume # step past the colon
        |> State.consume_whitespace # if current token is whitespace, step past it

      State.debug(state, "consumed colon and whitespace, currently: #{inspect state.token}")

      {state, declaration} = consume_a_declaration(state, %ExCss.Parser.Nodes.Declaration{name: name, value: []})

      value =
        declaration.value
        |> Enum.reverse
        |> List.to_tuple

      declaration = %{declaration | value: value}
      {state, declaration}
    end
  end
  defp consume_a_declaration(state, declaration) do
    # While the current input token is anything other than an <EOF-token>,
    # append it to the declaration’s value and consume the next input token.
    {state, component_value} = State.consume_component_value(state)

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
      state = State.new(declaration.value) |> State.consume_whitespace

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
