defmodule ConsumersHashTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "not opening a hash/id" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(TestHelper.state_for("abc "))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "opening a hash/id" do
      context "its not followed by any proper char" do
        it "returns a delim token and only advances the #" do
          {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(TestHelper.state_for("# potato"))
          expect(token) |> to_eq({:delim, {"#"}})
          expect(new_state.pos) |> to_eq(0)
        end
      end

      context "it starts with a name_char" do
        context "but can't be the start of an identifier" do # this won't work with all hex strings, ok?
          it "returns a hash token" do
            {new_state, token} = ExCss.Lexer.Consumers.Hash.accept(TestHelper.state_for("#0f31f5 "))
            expect(token) |> to_eq({:hash, {"0f31f5"}})
            expect(new_state.pos) |> to_eq(6)
          end
        end

        context "and is the start of an identifier" do
          it "returns an id token" do
            {new_state, token}  = ExCss.Lexer.Consumers.Hash.accept(TestHelper.state_for("#this_is_a_test something"))
            expect(token) |> to_eq({:hash, {"this_is_a_test"}})
            expect(new_state.pos) |> to_eq(14)
          end
        end
      end
    end
  end
end
