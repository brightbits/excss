defmodule ConsumersPlusTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".accept" do
    context "doesn't match +" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Plus.accept(TestHelper.state_for("123"))
        expect(new_state.pos) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches +" do
      context "and the following looks like a number" do
        it "returns a number token"  do
          {new_state, token} = ExCss.Lexer.Consumers.Plus.accept(TestHelper.state_for("+123.456 test"))
          expect(new_state.pos) |> to_eq(7)
          expect(token) |> to_eq({:number, {123.456, "+123.456"}})
        end

        it "works with dimensions also" do
          {new_state, token} = ExCss.Lexer.Consumers.Plus.accept(TestHelper.state_for("+123.456em test"))
          expect(new_state.pos) |> to_eq(9)
          expect(token) |> to_eq({:dimension, {123.456, "+123.456", "em"}})
        end

        it "works with percentages also" do
          {new_state, token} = ExCss.Lexer.Consumers.Plus.accept(TestHelper.state_for("+123.456% test"))
          expect(new_state.pos) |> to_eq(8)
          expect(token) |> to_eq({:percentage, {123.456, "+123.456"}})
        end
      end

      context "its not followed by a number" do
        it "returns a delim and advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.Plus.accept(TestHelper.state_for("+cat"))
          expect(new_state.pos) |> to_eq(0)
          expect(token) |> to_eq({:delim, {"+"}})
        end
      end
    end
  end
end
