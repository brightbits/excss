defmodule SharedTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State

  describe ".consume_escape_char" do
    context "its just a char" do
      it "returns the correct state and char" do
        {new_state, char} = ExCss.Lexer.Shared.consume_escaped_char(State.new("\\\"", -1))
        expect(new_state.i) |> to_eq(1)
        expect(char) |> to_eq("\"")
      end
    end

    context "its a hex string" do
      it "returns the correct state and char" do
        {new_state, char} = ExCss.Lexer.Shared.consume_escaped_char(State.new("\\c582", -1))
        expect(new_state.i) |> to_eq(4)
        expect(char) |> to_eq("ł")
      end
    end
  end

  describe ".digit?" do
    it "returns true for 0-9 and false for anything else" do
       expect(ExCss.Lexer.Shared.digit?("0")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("1")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("2")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("3")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("4")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("5")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("6")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("7")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("8")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("9")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.digit?("a")) |> to_eq(false)
       expect(ExCss.Lexer.Shared.digit?(" ")) |> to_eq(false)
       expect(ExCss.Lexer.Shared.digit?("$")) |> to_eq(false)
    end
  end

  describe ".hex_digit?" do
    it "returns true for 0-9 A-F a-f and false for anything else" do
       expect(ExCss.Lexer.Shared.hex_digit?("0")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("1")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("2")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("3")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("4")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("5")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("6")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("7")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("8")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("9")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("a")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("b")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("c")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("d")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("e")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("f")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("A")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("B")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("C")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("D")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("E")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("F")) |> to_eq(true)
       expect(ExCss.Lexer.Shared.hex_digit?("g")) |> to_eq(false)
       expect(ExCss.Lexer.Shared.hex_digit?("G")) |> to_eq(false)
    end
  end

  describe ".consume_whitespace" do
    context "next character isn't whitespace" do
      it "doesn't consume anything" do
        new_state = ExCss.Lexer.Shared.consume_whitespace(State.new("cat"))
        expect(new_state.i) |> to_eq(-1)
      end
    end

    context "next character is whitespace" do
      it "consumes all the whitespace, stopping at the next non whitespace char" do
        new_state = ExCss.Lexer.Shared.consume_whitespace(State.new(" \t\n  \t  cat"))

        expect(new_state.i) |> to_eq(7)
      end
    end
  end
end
