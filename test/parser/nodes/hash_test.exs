defmodule ExCss.Parser.Nodes.HashTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "has a hash" do
      it "parses correctly" do
        tokens = [
          %Tokens.Hash{value: "hello"}
        ]

        {_, hash} = Nodes.Hash.parse(State.new(tokens))

        expect(hash) |> to_eq(%Nodes.Hash{value: "hello"})
      end
    end

    context "doesn't have an hash" do
      it "returns nil" do
        tokens = [
          %Tokens.Number{value: 123}
        ]

        {_, hash} = Nodes.Hash.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end
  end
end
