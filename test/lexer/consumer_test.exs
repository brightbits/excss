defmodule ConsumersTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".consume" do
    let :state do
      %{str: "this is a test", pos: -1}
    end

    it "updates the state correctly" do
      new_state = ExCss.Lexer.Consumer.consume(state)
      expect(new_state) |> to_eq(%{str: "this is a test", pos: 0, char: "t"})
    end

    context "already some way in to the string" do
      let :state do
        %{str: "this is a test", pos: 3}
      end

      it "updates the state correctly" do
        new_state = ExCss.Lexer.Consumer.consume(state)
        expect(new_state) |> to_eq(%{str: "this is a test", pos: 4, char: " "})
      end
    end

    context "outside the bounds of str" do
      let :state do
        %{str: "this", pos: 3}
      end

      it "updates the state correctly" do
        new_state = ExCss.Lexer.Consumer.consume(state)
        expect(new_state) |> to_eq(%{str: "this", pos: 4, char: nil})
      end
    end

    context "last character" do
      let :state do
        %{str: "test", pos: 2}
      end

      it "returns the last character" do
        new_state = ExCss.Lexer.Consumer.consume(state)
        expect(new_state) |> to_eq(%{str: "test", pos: 3, char: "t"})
      end
    end
  end

  describe ".peek" do
    let :state do
      %{str: "this is a test", pos: -1}
    end

    it "returns the next character" do
      expect(ExCss.Lexer.Consumer.peek(state)) |> to_eq("t")
    end

    context "already some way in to the string" do
      let :state do
        %{str: "this is a test", pos: 3}
      end

      it "returns the next character" do
        expect(ExCss.Lexer.Consumer.peek(state)) |> to_eq(" ")
      end
    end

    context "outside the bounds of str" do
      let :state do
        %{str: "this", pos: 3}
      end

      it "return nil" do
        expect(ExCss.Lexer.Consumer.peek(state)) |> to_be_nil
      end
    end

    context "asking for the second character" do
      let :state do
        %{str: "this is a test", pos: -1}
      end

      it "returns the character after the next character" do
        expect(ExCss.Lexer.Consumer.peek(state, 2)) |> to_eq("h")
      end

      context "outside the bounds of str" do
        let :state do
          %{str: "this", pos: 2}
        end

        it "returns nil" do
          expect(ExCss.Lexer.Consumer.peek(state, 2)) |> to_be_nil
        end
      end
    end
  end

  describe ".consume_escape_char" do
    context "its just a char" do
      it "returns the correct state and char" do
        {new_state, char} = ExCss.Lexer.Consumer.consume_escaped_char(TestHelper.state_for("\\\"", -1))
        expect(new_state.pos) |> to_eq(1)
        expect(char) |> to_eq("\"")
      end
    end

    context "its a hex string" do
      it "returns the correct state and char" do
        {new_state, char} = ExCss.Lexer.Consumer.consume_escaped_char(TestHelper.state_for("\\c582", -1))
        expect(new_state.pos) |> to_eq(4)
        expect(char) |> to_eq("ł")
      end
    end
  end

  describe ".digit?" do
    it "returns true for 0-9 and false for anything else" do
       expect(ExCss.Lexer.Consumer.digit?("0")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("1")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("2")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("3")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("4")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("5")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("6")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("7")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("8")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("9")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.digit?("a")) |> to_eq(false)
       expect(ExCss.Lexer.Consumer.digit?(" ")) |> to_eq(false)
       expect(ExCss.Lexer.Consumer.digit?("$")) |> to_eq(false)
    end
  end

  describe ".hex_digit?" do
    it "returns true for 0-9 A-F a-f and false for anything else" do
       expect(ExCss.Lexer.Consumer.hex_digit?("0")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("1")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("2")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("3")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("4")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("5")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("6")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("7")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("8")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("9")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("a")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("b")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("c")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("d")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("e")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("f")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("A")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("B")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("C")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("D")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("E")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("F")) |> to_eq(true)
       expect(ExCss.Lexer.Consumer.hex_digit?("g")) |> to_eq(false)
       expect(ExCss.Lexer.Consumer.hex_digit?("G")) |> to_eq(false)
    end
  end

  describe ".consume_whitespace" do
    context "next character isn't whitespace" do
      it "doesn't consume anything" do
        new_state = ExCss.Lexer.Consumer.consume_whitespace(TestHelper.state_for("cat"))
        expect(new_state.pos) |> to_eq(-1)
      end
    end

    context "next character is whitespace" do
      it "consumes all the whitespace, stopping at the next non whitespace char" do
        new_state = ExCss.Lexer.Consumer.consume_whitespace(TestHelper.state_for(" \t\n  \t  cat"))

        expect(new_state.pos) |> to_eq(7)
      end
    end
  end
end
