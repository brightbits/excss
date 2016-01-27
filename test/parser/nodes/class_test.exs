defmodule ExCss.Parser.Nodes.ClassTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "has an id" do
      it "parses correctly" do
        tokens = [
          %Tokens.Delim{value: "."},
          %Tokens.Id{value: "test"}
        ]

        {_, class} = Nodes.Class.parse(State.new(tokens))

        expect(class) |> to_eq(%Nodes.Class{value: "test"})
      end
    end
    context "doesn't have an id" do
      it "returns nil" do
        tokens = [
          %Tokens.Delim{value: "."},
          %Tokens.Number{value: 123}
        ]

        {_, class} = Nodes.Class.parse(State.new(tokens))

        expect(class) |> to_be_nil
      end
    end
  end
end
