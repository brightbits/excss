defmodule ConsumersCloseCurlyTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match }" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.CloseCurly.accept(State.new("{abc}", 2))
        expect(new_state.i) |> to_eq(2)
        expect(token) |> to_be_nil
      end
    end

    context "matches }" do
      it "returns an close curly advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.CloseCurly.accept(State.new("{abc}", 3))
        expect(new_state.i) |> to_eq(4)
        expect(token) |> to_eq(%Tokens.CloseCurly{})
      end
    end
  end
end
