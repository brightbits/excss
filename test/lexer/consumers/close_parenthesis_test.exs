defmodule ConsumersCloseParenthesisTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match )" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.CloseParenthesis.accept(TestHelper.state_for("(abc)", 2))
        expect(new_state.pos) |> to_eq(2)
        expect(token) |> to_be_nil
      end
    end

    context "matches )" do
      it "returns an close parenthesis advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.CloseParenthesis.accept(TestHelper.state_for("(abc)", 3))
        expect(new_state.pos) |> to_eq(4)
        expect(token) |> to_eq({:close_parenthesis, {}})
      end
    end
  end
end
