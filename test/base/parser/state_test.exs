defmodule ExCss.Parser.StateTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens, as: T
  alias ExCss.Parser.State

  describe ".consume_whitespace" do
    context "currently on whitespace" do
      it "consumes the whitespace and returns the new state" do
        tokens = [
          %T.Id{value: "Blah"},
          %T.Whitespace{},
          %T.Id{value: "Test"}
        ]

        state = State.new(tokens) |> State.consume

        expect(state.token) |> to_eq(%T.Whitespace{})

        state = State.consume_whitespace(state)

        expect(state.token) |> to_eq(%T.Id{value: "Test"})
      end
    end

    context "not currently on whitespace" do
      it "consumes the whitespace and returns the new state" do
        tokens = [
          %T.Id{value: "Blah"},
          %T.Whitespace{},
          %T.Id{value: "Test"}
        ]

        state = State.new(tokens)

        expect(state.token) |> to_eq(%T.Id{value: "Blah"})

        state = State.consume_whitespace(state)

        expect(state.token) |> to_eq(%T.Id{value: "Blah"})
      end
    end
  end
end
