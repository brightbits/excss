defmodule ConsumersCommentTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "next 2 characters aren't the start of a comment" do
      let :state, do: ExCss.Lexer.State.new("this is a test")

      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Comment.accept(state)
        expect(new_state) |> to_eq(state)
        expect(token) |> to_be_nil
      end
    end

    context "next 2 characters are the start of a comment and the end is before the EOF" do
      let :state, do: ExCss.Lexer.State.new("this /* is a test */ test", 4)

      it "returns a state advanced to the last character of the comment and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Comment.accept(state)
        expect(new_state.i) |> to_eq(19)
        expect(token) |> to_be_nil
      end
    end

    context "next 2 characters are the start of a comment and the end is not before the EOF" do
      let :state, do: ExCss.Lexer.State.new("this /* is a test", 4)

      it "returns the last state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Comment.accept(state)
        expect(new_state.i) |> to_eq(17)
        expect(token) |> to_be_nil
      end
    end
  end
end
