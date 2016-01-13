defmodule ConsumersOpenParenthesisTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match (" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.OpenParenthesis.accept(TestHelper.state_for("(abc)", 0))
        expect(new_state.pos) |> to_eq(0)
        expect(token) |> to_be_nil
      end
    end

    context "matches (" do
      it "returns an open parenthesis advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.OpenParenthesis.accept(TestHelper.state_for("(abc)"))
        expect(new_state.pos) |> to_eq(0)
        expect(token) |> to_eq({:open_parenthesis, {}})
      end
    end
  end
end
