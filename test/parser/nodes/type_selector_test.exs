defmodule ExCss.Parser.Nodes.TypeSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "not an id" do
      it "returns nil" do
        tokens = [
          %T.Whitespace{}
        ]

        {_, selector} = N.TypeSelector.parse(State.new(tokens))

        expect(selector) |> to_be_nil
      end
    end
    context "with an id" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "h1"}
        ]

        {_, selector} = N.TypeSelector.parse(State.new(tokens))

        expect(selector) |> to_eq(%N.TypeSelector{value: "h1"})
      end
    end
  end
end
