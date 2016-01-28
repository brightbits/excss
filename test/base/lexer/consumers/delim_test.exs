defmodule ConsumersDelimTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "its eof" do
      it "returns an unchanged state and an eof token" do
        {new_state, token} = ExCss.Lexer.Consumers.Delim.accept(State.new(""))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_eq(%Tokens.EndOfFile{})
      end
    end

    context "its not eof" do
      it "returns a delim token advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.Delim.accept(State.new("£"))
        expect(new_state.i) |> to_eq(0)
        expect(token) |> to_eq(%Tokens.Delim{value: "£"})
      end
    end
  end
end
