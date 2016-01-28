defmodule ExCss.Selectors.Nodes.CombinatorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "next is a + with some whitespace" do
      it "returns an adjacent_sibling combinator and consumes whitespace after it" do
        tokens = [
          %T.Whitespace{},
          %T.Delim{value: "+"},
          %T.Whitespace{}
        ]

        {state, combinator} = N.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%T.EndOfFile{})

        expect(combinator) |> to_eq(%N.Combinator{
          type: :adjacent_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a +" do
      it "returns an adjacent_sibling combinator and consumes whitespace after it" do
        tokens = [
          %T.Delim{value: "+"},
          %T.Whitespace{}
        ]

        {state, combinator} = N.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%T.EndOfFile{})

        expect(combinator) |> to_eq(%N.Combinator{
          type: :adjacent_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a >" do
      it "returns an child combinator and consumes whitespace after it" do
        tokens = [
          %T.Delim{value: ">"},
          %T.Whitespace{}
        ]

        {state, combinator} = N.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%T.EndOfFile{})

        expect(combinator) |> to_eq(%N.Combinator{
          type: :child,
          left: nil,
          right: nil
        })
      end
    end

    context "next is a ~" do
      it "returns an general_sibling combinator and consumes whitespace after it" do
        tokens = [
          %T.Delim{value: "~"},
          %T.Whitespace{}
        ]

        {state, combinator} = N.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%T.EndOfFile{})

        expect(combinator) |> to_eq(%N.Combinator{
          type: :general_sibling,
          left: nil,
          right: nil
        })
      end
    end

    context "next is whitespace" do
      it "returns an descendant combinator and consumes whitespace" do
        tokens = [
          %T.Whitespace{},
          %T.Whitespace{}
        ]

        {state, combinator} = N.Combinator.parse(State.new(tokens))

        expect(state.token) |> to_eq(%T.EndOfFile{})

        expect(combinator) |> to_eq(%N.Combinator{
          type: :descendant,
          left: nil,
          right: nil
        })
      end
    end
  end
end
