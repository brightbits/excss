defmodule ConsumersPeriodTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match ." do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Period.accept(State.new("123"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches ." do
      context "and the following looks like a number" do
        it "returns a number token"  do
          {new_state, token} = ExCss.Lexer.Consumers.Period.accept(State.new(".123 test"))
          expect(new_state.i) |> to_eq(3)
          expect(token) |> to_eq(%Tokens.Number{value: 0.123, original_value: ".123"})
        end

        it "works with dimensions also" do
          {new_state, token} = ExCss.Lexer.Consumers.Period.accept(State.new(".456em test"))
          expect(new_state.i) |> to_eq(5)
          expect(token) |> to_eq(%Tokens.Dimension{value: 0.456, original_value: ".456", unit: "em"})
        end

        it "works with percentages also" do
          {new_state, token} = ExCss.Lexer.Consumers.Period.accept(State.new(".456% test"))
          expect(new_state.i) |> to_eq(4)
          expect(token) |> to_eq(%Tokens.Percentage{value: 0.456, original_value: ".456"})
        end
      end

      context "its not followed by a number" do
        it "returns a delim and advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.Period.accept(State.new(".cat"))
          expect(new_state.i) |> to_eq(0)
          expect(token) |> to_eq(%Tokens.Delim{value: "."})
        end
      end
    end
  end
end
