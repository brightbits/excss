defmodule ExCss.Parser.Nodes.HashTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "has a hash" do
      it "parses correctly" do
        tokens = [
          %T.Hash{value: "hello"}
        ]

        {_, hash} = N.Hash.parse(State.new(tokens))

        expect(hash) |> to_eq(%N.Hash{value: "hello"})
      end
    end

    context "doesn't have an hash" do
      it "returns nil" do
        tokens = [
          %T.Number{value: 123}
        ]

        {_, hash} = N.Hash.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end
  end
end
