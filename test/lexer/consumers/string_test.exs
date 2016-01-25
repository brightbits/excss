defmodule ConsumersStringTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "not opening a string" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("abc"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "is opening a string" do
      it "returns a string token and advances the state until the end of the string" do
        {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa\"this is a test\" test", 2))
        expect(new_state.i) |> to_eq(18)
        expect(token) |> to_eq(%Tokens.String{value: "this is a test", wrapped_by: "\""})
      end

      it "works with a single quoted string too" do
        {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa'this is a test' test", 2))
        expect(new_state.i) |> to_eq(18)
        expect(token) |> to_eq(%Tokens.String{value: "this is a test", wrapped_by: "'"})
      end

      context "the string doesn't end before the EOF" do
        it "returns a string token and advances the state until the end of the string" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa\"this is a test", 2))
          expect(new_state.i) |> to_eq(18)
          expect(token) |> to_eq(%Tokens.String{value: "this is a test", wrapped_by: "\""})
        end
      end

      context "the string has a new line that isn't escaped" do
        it "returns a bad string token and adds a warning" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa\"this is a test\ncats\"", 2))
          expect(new_state.i) |> to_eq(17)
          expect(token) |> to_eq(%Tokens.BadString{})
          #expect(new_state.warnings) |> to_eq(["String wasn't closed before new line and the new line wasn't escaped"])
        end
      end

      context "the string has a new line that is escaped" do
        it "returns a string token" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa\"this is a test\\\ncats\"", 2))
          expect(new_state.i) |> to_eq(24)
          expect(token) |> to_eq(%Tokens.String{value: "this is a testcats", wrapped_by: "\""})
        end
      end

      context "the string has an escape before the end of the file" do
        it "returns a string token" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa\"this is a test\\", 2))
          expect(token) |> to_eq(%Tokens.String{value: "this is a test", wrapped_by: "\""})
          expect(new_state.i) |> to_eq(19)
        end
      end

      context "the string has an escaped quote" do
        it "returns a string token" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa \"this is a \\\"test\" :)", 3))
          expect(token) |> to_eq(%Tokens.String{value: "this is a \"test", wrapped_by: "\""})
          expect(new_state.i) |> to_eq(21)
        end
      end

      context "the string has an escaped hex" do
        it "returns a string token" do
          {new_state, token} = ExCss.Lexer.Consumers.String.accept(State.new("aaa \"this is a \\c582 :)\"", 3))
          expect(token) |> to_eq(%Tokens.String{value: "this is a ł :)", wrapped_by: "\""})
          expect(new_state.i) |> to_eq(23)
        end
      end
    end
  end
end
