defmodule ConsumersMinusTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match -" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("123"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches -" do
      context "and the following looks like a number" do
        it "returns a number token"  do
          {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-123.456 test"))
          expect(new_state.i) |> to_eq(7)
          expect(token) |> to_eq(%Tokens.Number{value: -123.456, original_value: "-123.456"})
        end

        it "works with dimensions also" do
          {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-123.456em test"))
          expect(new_state.i) |> to_eq(9)
          expect(token) |> to_eq(%Tokens.Dimension{value: -123.456, original_value: "-123.456", unit: "em"})
        end

        it "works with percentages also" do
          {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-123.456% test"))
          expect(new_state.i) |> to_eq(8)
          expect(token) |> to_eq(%Tokens.Percentage{value: -123.456, original_value: "-123.456"})
        end
      end

      context "and the following looks like an identifier" do
        it "returns an id token" do
          {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-webkit-property cats"))
          expect(new_state.i) |> to_eq(15)
          expect(token) |> to_eq(%Tokens.Id{value: "-webkit-property"})
        end
      end

      context "its not followed by a number" do
        context "but is followed by ->" do
          it "returns a cdc and swallows it" do
            {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-->"))
            expect(new_state.i) |> to_eq(2)
            expect(token) |> to_eq(%Tokens.CDC{})
          end
        end

        context "not followed by ->" do
          it "returns a delim and advances 1 char" do
            {new_state, token} = ExCss.Lexer.Consumers.Minus.accept(State.new("-$"))
            expect(new_state.i) |> to_eq(0)
            expect(token) |> to_eq(%Tokens.Delim{value: "-"})
          end
        end
      end
    end
  end
end
