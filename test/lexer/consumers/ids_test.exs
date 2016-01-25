defmodule ConsumersIdsTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match a name start char" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(State.new("%"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "matches a name start char" do
      context "its a url" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(State.new("url(potato)", -1))
        expect(new_state.i) |> to_eq(10)
        expect(token) |> to_eq(%Tokens.Url{value: "potato"})
      end

      context "its a function" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(State.new("url('potato')", -1))
        expect(new_state.i) |> to_eq(3)
        expect(token) |> to_eq(%Tokens.Function{value: "url"})
      end

      context "its an id" do
        {new_state, token} = ExCss.Lexer.Consumers.Ids.accept(State.new("potato man", -1))
        expect(new_state.i) |> to_eq(5)
        expect(token) |> to_eq(%Tokens.Id{value: "potato"})
      end
    end
  end
end
