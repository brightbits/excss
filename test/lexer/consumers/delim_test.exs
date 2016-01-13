defmodule ConsumersDelimTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "its eof" do
      it "returns an unchanged state and an eof token" do
        {new_state, token} = ExCss.Lexer.Consumers.Delim.accept(TestHelper.state_for(""))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_eq({:eof, {}})
      end
    end

    context "its not eof" do
      it "returns a delim token advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.Delim.accept(TestHelper.state_for("£"))
        expect(new_state.pos) |> to_eq(0)
        expect(token) |> to_eq({:delim, {"£"}})
      end
    end
  end
end
