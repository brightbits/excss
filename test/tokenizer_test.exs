defmodule TokenizerTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".new" do
    it "returns the correct starting state" do
      expect(ExCss.Tokenizer.new("this is a test")) |> to_eq(%{str: "this is a test", pos: -1, warnings: []})
    end
  end

  describe ".next" do
    it "works correctly" do
       state = ExCss.Tokenizer.new("/* this is a test */     \"test cats\"")

       {state, token} = ExCss.Tokenizer.next(state)
       expect(token) |> to_eq({:comment, " this is a test "})
       expect(state.pos) |> to_eq(19)

       {state, token} = ExCss.Tokenizer.next(state)
       expect(token) |> to_eq({:whitespace})
       expect(state.pos) |> to_eq(24)

       {state, token} = ExCss.Tokenizer.next(state)
       expect(token) |> to_eq({:string, "test cats"})
       expect(state.pos) |> to_eq(35)
    end
  end
end
