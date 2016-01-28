defmodule ConsumersHashTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "not opening a hash/id" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(State.new("abc "))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "opening a hash/id" do
      context "its not followed by any proper char" do
        it "returns a delim token and only advances the #" do
          {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(State.new("# potato"))
          expect(token) |> to_eq(%Tokens.Delim{value: "#"})
          expect(new_state.i) |> to_eq(0)
        end
      end

      context "it starts with a name_char" do
        context "but can't be the start of an identifier" do # this won't work with all hex strings, ok?
          it "returns a hash token" do
            {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(State.new("#0f31f5 "))
            expect(token) |> to_eq(%Tokens.Hash{value: "0f31f5"})
            expect(new_state.i) |> to_eq(6)
          end
        end

        context "and is the start of an identifier" do
          it "returns an hash token with id true" do
            {new_state, token}  = ExCss.Lexer.Consumers.Hash.accept(State.new("#this_is_a_test something"))
            expect(token) |> to_eq(%Tokens.Hash{value: "this_is_a_test", id: true})
            expect(new_state.i) |> to_eq(14)
          end
        end
      end
    end
  end
end
