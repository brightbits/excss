# selector
#   : simple_selector_sequence [ combinator simple_selector_sequence ]*
#   ;

defmodule ExCss.Parser.Nodes.Selector do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  
  defstruct value: nil

  def pretty_print(selector, indent) do
    PrettyPrint.pretty_out("Selector:", indent)
    PrettyPrint.pretty_out(selector.value, indent + 1)
  end

  def parse(state) do
    state |> State.debug("-- CONSUMING A SELECTOR --")

    {state, simple_selector} = N.SimpleSelector.parse(state)

    if simple_selector do
      {state, combinators} = consume_combinators(state, simple_selector)
      {state, %N.Selector{value: combinators}}
    else
      {state, nil}
    end
  end

  defp consume_combinators(state, simple_selector) do
    state |> State.debug("before comb: #{inspect state.token}")
    {state, combinator} = N.Combinator.parse(state)

    if combinator do
      state |> State.debug("got a combinator: #{inspect combinator}")

      state |> State.debug("before SS: #{inspect state.token}")

      {state, another_selector} = N.Selector.parse(state)

      state |> State.debug("after SS: #{inspect another_selector} --- #{inspect state.token}")

      if another_selector do
        {state, %{combinator | left: simple_selector, right: another_selector.value}}
      else
        # we picked up a descendant combinator, but there is nothing after it,
        # so pretend it was just whitespace and return the original simple_selector
        if combinator.type == :descendant do
          State.debug(state, "Just returning simple selector instead")
          {state, simple_selector}
        else
          {state, nil}
        end
      end
    else
      state |> State.debug("no combinator, returning just the simple selector")
      {state, simple_selector}
    end
  end
end
