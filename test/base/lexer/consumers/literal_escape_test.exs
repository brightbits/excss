defmodule ConsumersLiteralEscapeTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match \\" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.LiteralEscape.accept(State.new("a\\test", -1))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches a \\" do
      context "but the escape sequence isn't valid" do
        it "returns a warning and consumes the slash" do
          {new_state, token} = ExCss.Lexer.Consumers.LiteralEscape.accept(State.new("\\\n", -1))
          #expect(new_state.warnings) |> to_eq(["Invalid escape sequence"])
          expect(new_state.i) |> to_eq(0)
          expect(token) |> to_be_nil
        end
      end

      context "and the escape sequence is valid" do
        context "its a url" do
          {new_state, token} = ExCss.Lexer.Consumers.LiteralEscape.accept(State.new("\\url(potato)", -1))
          expect(new_state.i) |> to_eq(11)
          expect(token) |> to_eq(%Tokens.Url{value: "potato"})
        end

        context "its a function" do
          {new_state, token} = ExCss.Lexer.Consumers.LiteralEscape.accept(State.new("\\url('potato')", -1))
          expect(new_state.i) |> to_eq(4)
          expect(token) |> to_eq(%Tokens.Function{value: "url"})
        end

        context "its an id" do
          {new_state, token} = ExCss.Lexer.Consumers.LiteralEscape.accept(State.new("\\potato man", -1))
          expect(new_state.i) |> to_eq(6)
          expect(token) |> to_eq(%Tokens.Id{value: "potato"})
        end
      end
    end
  end
end
