defmodule ConsumersPrefixMatchTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "not starting with a $" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.PrefixMatch.accept(TestHelper.state_for("abc"))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "starts with a $" do
      context "but not followed by a =" do
        it "returns a delim of ^ and advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.PrefixMatch.accept(TestHelper.state_for("^abc"))
          expect(new_state.pos) |> to_eq(0)
          expect(token) |> to_eq({:delim, {"^"}})
        end
      end

      context "followed by a =" do
        it "returns a prefix match and advances 2 chars" do
          {new_state, token} = ExCss.Lexer.Consumers.PrefixMatch.accept(TestHelper.state_for("^=abc"))
          expect(new_state.pos) |> to_eq(1)
          expect(token) |> to_eq({:prefix_match, {}})
        end
      end
    end
  end
end
