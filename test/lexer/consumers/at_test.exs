defmodule ConsumersAtTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match @" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.At.accept(TestHelper.state_for("@abc", 0))
        expect(new_state.pos) |> to_eq(0)
        expect(token) |> to_be_nil
      end
    end

    context "matches @" do
      context "the next few chars look like an identifier" do
        it "returns a at_keyword token advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.At.accept(TestHelper.state_for("@media", -1))
          expect(token) |> to_eq({:at_keyword, {"media"}})
          expect(new_state.pos) |> to_eq(5)
        end
      end

      context "the next few chars don't look like an identifier" do
        it "returns a delim token advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.At.accept(TestHelper.state_for("@ ", -1))
          expect(token) |> to_eq({:delim, {"@"}})
          expect(new_state.pos) |> to_eq(0)
        end
      end
    end
  end
end
