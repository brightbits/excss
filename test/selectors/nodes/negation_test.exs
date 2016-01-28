defmodule ExCss.Selectors.Nodes.NegationTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "has the not function" do
      context "type selector" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "NoT"},
            %T.Whitespace{},
            %T.Id{value: "h1"},
            %T.Whitespace{},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.TypeSelector{
              value: "h1"
            }
          })
        end
      end

      context "universal selector" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "not"},
            %T.Delim{value: "*"},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.UniversalSelector{}
          })
        end
      end

      context "hash" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "NoT"},
            %T.Hash{value: "container"},
            %T.Whitespace{},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.Hash{value: "container"}
          })
        end
      end

      context "class" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "NoT"},
            %T.Delim{value: "."},
            %T.Id{value: "my-class"},
            %T.Whitespace{},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.Class{value: "my-class"}
          })
        end
      end

      context "attrib" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "NoT"},
            %T.OpenSquare{},
            %T.Id{value: "attribute"},
            %T.CloseSquare{},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.Attribute{value: "attribute"}
          })
        end
      end

      context "pseudo" do
        it "parses correctly" do
          tokens = [
            %T.Function{value: "NoT"},
            %T.Colon{},
            %T.Colon{},
            %T.Id{value: "first-child"},
            %T.CloseParenthesis{}
          ]

          {_, negation} = N.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%N.Negation{
            value: %N.Pseudo{value: "first-child", type: :element}
          })
        end
      end
    end

    context "doesn't have the not function" do
      it "returns nil" do
        tokens = [
          %T.Function{value: "n0t"},
          %T.Whitespace{},
          %T.Id{value: "h1"}
        ]

        {_, hash} = N.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end

    context "missing a closing parenthesis" do
      it "returns nil" do
        tokens = [
          %T.Function{value: "not"},
          %T.Whitespace{},
          %T.Id{value: "h1"}
        ]

        {_, hash} = N.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end

    context "invalid arg" do
      it "returns nil" do
        tokens = [
          %T.Function{value: "not"},
          %T.Whitespace{},
          %T.Number{value: 42},
          %T.CloseParenthesis{}
        ]

        {_, hash} = N.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end
  end
end
