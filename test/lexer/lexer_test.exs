defmodule LexerTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".new" do
    it "returns the correct starting state" do
      expect(ExCss.Lexer.new("this is a test")) |> to_eq(%{str: "this is a test", pos: -1, warnings: []})
    end
  end

  describe ".next" do
    it "works correctly" do
       state = ExCss.Lexer.new("/* this is a test */     \"test cats\"\t$\n\n\n      $=#an_id")

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:comment, {" this is a test "}})
       expect(state.pos) |> to_eq(19)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:whitespace, {}})
       expect(state.pos) |> to_eq(24)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:string, {"test cats"}})
       expect(state.pos) |> to_eq(35)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:whitespace, {}})
       expect(state.pos) |> to_eq(36)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:delim, {"$"}})
       expect(state.pos) |> to_eq(37)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:whitespace, {}})
       expect(state.pos) |> to_eq(46)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:suffix_match, {}})
       expect(state.pos) |> to_eq(48)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:hash, {"an_id"}})
       expect(state.pos) |> to_eq(54)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq({:eof, {}})
       expect(state.pos) |> to_eq(54)
    end
  end
end
