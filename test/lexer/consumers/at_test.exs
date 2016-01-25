defmodule ConsumersAtTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match @" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.At.accept(State.new("@abc", 0))
        expect(new_state.i) |> to_eq(0)
        expect(token) |> to_be_nil
      end
    end

    context "matches @" do
      context "the next few chars look like an identifier" do
        it "returns a at_keyword token advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.At.accept(State.new("@media", -1))
          expect(token) |> to_eq(%Tokens.AtKeyword{value: "media"})
          expect(new_state.i) |> to_eq(5)
        end
      end

      context "the next few chars don't look like an identifier" do
        it "returns a delim token advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.At.accept(State.new("@ ", -1))
          expect(token) |> to_eq(%Tokens.Delim{value: "@"})
          expect(new_state.i) |> to_eq(0)
        end
      end
    end
  end
end
