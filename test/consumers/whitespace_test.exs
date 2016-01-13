defmodule ConsumersWhitespaceTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "not whitespace" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Consumers.Whitespace.accept(%{str: "abc", pos: -1})
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "is whitespace" do
      it "returns a whitespace token and advances the state until no more whitespace" do
        {new_state, token} = ExCss.Consumers.Whitespace.accept(%{str: "abc   test", pos: 3, char: " "})
        expect(new_state.pos) |> to_eq(5)
        expect(token) |> to_eq({:whitespace})
      end
    end
  end
end
