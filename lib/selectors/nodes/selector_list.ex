# selector_list
#   : WS? selector [ WS? COMMA WS? selector ]*
#   ;

defmodule ExCss.Selectors.Nodes.SelectorList do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Lexer.Tokens, as: T
  alias ExCss.Selectors.Nodes, as: N

  defstruct value: nil

  def pretty_print(selector, indent) do
    PrettyPrint.pretty_out("Selector List:", indent)
    PrettyPrint.pretty_out(selector.value, indent + 1)
  end

  def parse(state), do: parse(state, [])

  defp parse(state, acc) do
    state |> State.debug("-- CONSUMING A SELECTOR LIST --")

    state = State.consume_whitespace(state)

    {state, selector} = N.Selector.parse(state)

    if selector do
      acc = acc ++ [selector]

      state = State.consume_whitespace(state)

      if State.currently?(state, T.Comma) do
        parse(State.consume(state), acc)
      else
        {state, %N.SelectorList{value: acc}}
      end
    else
      {state, %N.SelectorList{value: []}}
    end
  end
end
