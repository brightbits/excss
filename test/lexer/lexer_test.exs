defmodule LexerTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens

  describe ".next" do
    it "works correctly" do
       state = ExCss.Lexer.State.new("/* this is a test */     \"test cats\"\t$\n\n\n      $=#an_id")

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Comment{value: " this is a test "})
       expect(state.i) |> to_eq(19)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Whitespace{})
       expect(state.i) |> to_eq(24)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.String{value: "test cats", wrapped_by: "\""})
       expect(state.i) |> to_eq(35)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Whitespace{})
       expect(state.i) |> to_eq(36)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Delim{value: "$"})
       expect(state.i) |> to_eq(37)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Whitespace{})
       expect(state.i) |> to_eq(46)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.SuffixMatch{})
       expect(state.i) |> to_eq(48)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.Hash{value: "an_id", id: true})
       expect(state.i) |> to_eq(54)

       {state, token} = ExCss.Lexer.next(state)
       expect(token) |> to_eq(%Tokens.EndOfFile{})
       expect(state.i) |> to_eq(54)
    end
  end
end
