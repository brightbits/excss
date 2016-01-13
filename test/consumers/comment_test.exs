defmodule ConsumersCommentTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "next 2 characters aren't the start of a comment" do
      let :state, do: TestHelper.state_for("this is a test")

      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Consumers.Comment.accept(state)
        expect(new_state) |> to_eq(state)
        expect(token) |> to_be_nil
      end
    end

    context "next 2 characters are the start of a comment and the end is before the EOF" do
      let :state, do: TestHelper.state_for("this /* is a test */ test", 4)

      it "returns a state advanced to the last character of the comment and a comment token" do
        {new_state, token} = ExCss.Consumers.Comment.accept(state)
        expect(new_state.pos) |> to_eq(19)
        expect(token) |> to_eq({:comment, " is a test "})
      end
    end

    context "next 2 characters are the start of a comment and the end is not before the EOF" do
      let :state, do: TestHelper.state_for("this /* is a test", 4)

      it "returns the last state and an error token" do
        {new_state, token} = ExCss.Consumers.Comment.accept(state)
        expect(new_state.pos) |> to_eq(17)
        expect(token) |> to_eq({:error, "comment wasn't closed before the end of the file"})
      end
    end
  end
end
