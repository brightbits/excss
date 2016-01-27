defmodule ExCss.Parser.Nodes.UniversalSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "not a *" do
      it "returns nil" do
        tokens = [
          %Tokens.Id{value: "123"}
        ]

        {_, selector} = Nodes.UniversalSelector.parse(State.new(tokens))

        expect(selector) |> to_be_nil
      end
    end
    context "with a *" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Delim{value: "*"}
        ]

        {_, selector} = Nodes.UniversalSelector.parse(State.new(tokens))

        expect(selector) |> to_eq(%Nodes.UniversalSelector{})
      end
    end
  end
end
