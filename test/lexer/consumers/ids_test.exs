defmodule ConsumersIdsTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match a name start char" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(TestHelper.state_for("%"))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches a name start char" do
      context "its a url" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(TestHelper.state_for("url(potato)", -1))
        expect(new_state.pos) |> to_eq(10)
        expect(token) |> to_eq({:url, {"potato"}})
      end

      context "its a function" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(TestHelper.state_for("url('potato')", -1))
        expect(new_state.pos) |> to_eq(3)
        expect(token) |> to_eq({:function, {"url"}})
      end

      context "its an id" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(TestHelper.state_for("potato man", -1))
        expect(new_state.pos) |> to_eq(5)
        expect(token) |> to_eq({:id, {"potato"}})
      end
    end
  end
end
