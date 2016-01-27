defmodule ExCss.Parser.Nodes.TypeSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "not an id" do
      it "returns nil" do
        tokens = [
          %Tokens.Whitespace{}
        ]

        {_, selector} = Nodes.TypeSelector.parse(State.new(tokens))

        expect(selector) |> to_be_nil
      end
    end
    context "with an id" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "h1"}
        ]

        {_, selector} = Nodes.TypeSelector.parse(State.new(tokens))

        expect(selector) |> to_eq(%Nodes.TypeSelector{value: "h1"})
      end
    end
  end
end
