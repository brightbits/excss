defmodule ConsumersColonTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match :" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Colon.accept(State.new("1:2:3", -1))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches :" do
      it "returns a semicolon token advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.Colon.accept(State.new("1:2:3", 0))
        expect(new_state.i) |> to_eq(1)
        expect(token) |> to_eq(%Tokens.Colon{})
      end
    end
  end
end
