defmodule ExCss.Selectors.Nodes.ClassTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "has an id" do
      it "parses correctly" do
        tokens = [
          %T.Delim{value: "."},
          %T.Id{value: "test"}
        ]

        {_, class} = N.Class.parse(State.new(tokens))

        expect(class) |> to_eq(%N.Class{value: "test"})
      end
    end
    context "doesn't have an id" do
      it "returns nil" do
        tokens = [
          %T.Delim{value: "."},
          %T.Number{value: 123}
        ]

        {_, class} = N.Class.parse(State.new(tokens))

        expect(class) |> to_be_nil
      end
    end
  end
end
