defmodule ConsumersCommaTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match ," do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Comma.accept(TestHelper.state_for("1,2,3", -1))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches ," do
      it "returns a comma token advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.Comma.accept(TestHelper.state_for("1,2,3", 0))
        expect(new_state.pos) |> to_eq(1)
        expect(token) |> to_eq({:comma, {}})
      end
    end
  end
end
