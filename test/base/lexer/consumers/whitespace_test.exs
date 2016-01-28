defmodule ConsumersWhitespaceTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "not whitespace" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.Whitespace.accept(State.new("abc"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "is whitespace" do
      it "returns a whitespace token and advances the state until no more whitespace" do
        {new_state, token} = ExCss.Lexer.Consumers.Whitespace.accept(State.new("abc   test", 3))
        expect(new_state.i) |> to_eq(5)
        expect(token) |> to_eq(%Tokens.Whitespace{})
      end
    end
  end
end
