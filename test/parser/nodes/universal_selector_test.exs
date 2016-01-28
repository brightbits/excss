defmodule ExCss.Parser.Nodes.UniversalSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "not a *" do
      it "returns nil" do
        tokens = [
          %T.Id{value: "123"}
        ]

        {_, selector} = N.UniversalSelector.parse(State.new(tokens))

        expect(selector) |> to_be_nil
      end
    end
    context "with a *" do
      it "parses it correctly" do
        tokens = [
          %T.Delim{value: "*"}
        ]

        {_, selector} = N.UniversalSelector.parse(State.new(tokens))

        expect(selector) |> to_eq(%N.UniversalSelector{})
      end
    end
  end
end
