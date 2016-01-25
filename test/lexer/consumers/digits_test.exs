defmodule ConsumersDigitsTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match a digit" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Digits.accept(State.new("a123"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches a digit" do
      context "and the following looks like a number" do
        it "returns a number token"  do
          {new_state, token} = ExCss.Lexer.Consumers.Digits.accept(State.new("123.456 test"))
          expect(new_state.i) |> to_eq(6)
          expect(token) |> to_eq(%Tokens.Number{value: 123.456, original_value: "123.456"})
        end

        it "works with dimensions also" do
          {new_state, token} = ExCss.Lexer.Consumers.Digits.accept(State.new("123.456em test"))
          expect(new_state.i) |> to_eq(8)
          expect(token) |> to_eq(%Tokens.Dimension{value: 123.456, original_value: "123.456", unit: "em"})
        end

        it "works with percentages also" do
          {new_state, token} = ExCss.Lexer.Consumers.Digits.accept(State.new("123.456% test"))
          expect(new_state.i) |> to_eq(7)
          expect(token) |> to_eq(%Tokens.Percentage{value: 123.456, original_value: "123.456"})
        end
      end
    end
  end
end
