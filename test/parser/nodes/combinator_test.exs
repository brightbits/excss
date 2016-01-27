defmodule ExCss.Parser.Nodes.CombinatorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "next is a + with some whitespace" do
      it "returns an adjacent_sibling combinator and consumes whitespace after it" do
        tokens = [
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "+"},
          %Tokens.Whitespace{}
        ]

        {state, combinator} = Nodes.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})

        expect(combinator) |> to_eq(%Nodes.Combinator{
          type: :adjacent_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a +" do
      it "returns an adjacent_sibling combinator and consumes whitespace after it" do
        tokens = [
          %Tokens.Delim{value: "+"},
          %Tokens.Whitespace{}
        ]

        {state, combinator} = Nodes.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})

        expect(combinator) |> to_eq(%Nodes.Combinator{
          type: :adjacent_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a >" do
      it "returns an child combinator and consumes whitespace after it" do
        tokens = [
          %Tokens.Delim{value: ">"},
          %Tokens.Whitespace{}
        ]

        {state, combinator} = Nodes.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})

        expect(combinator) |> to_eq(%Nodes.Combinator{
          type: :child,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a ~" do
      it "returns an general_sibling combinator and consumes whitespace after it" do
        tokens = [
          %Tokens.Delim{value: "~"},
          %Tokens.Whitespace{}
        ]

        {state, combinator} = Nodes.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})

        expect(combinator) |> to_eq(%Nodes.Combinator{
          type: :general_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is whitespace" do
      it "returns an descendant combinator and consumes whitespace" do
        tokens = [
          %Tokens.Whitespace{},
          %Tokens.Whitespace{}
        ]

        {state, combinator} = Nodes.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})

        expect(combinator) |> to_eq(%Nodes.Combinator{
          type: :descendant,
          left: nil,
          right: nil
        })
      end
    end
  end
end
