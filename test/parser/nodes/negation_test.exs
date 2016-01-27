defmodule ExCss.Parser.Nodes.NegationTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "has the not function" do
      context "type selector" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "NoT"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "h1"},
            %Tokens.Whitespace{},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.TypeSelector{
              value: "h1"
            }
          })
        end
      end

      context "universal selector" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "not"},
            %Tokens.Delim{value: "*"},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.UniversalSelector{}
          })
        end
      end

      context "hash" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "NoT"},
            %Tokens.Hash{value: "container"},
            %Tokens.Whitespace{},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.Hash{value: "container"}
          })
        end
      end

      context "class" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "NoT"},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "my-class"},
            %Tokens.Whitespace{},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.Class{value: "my-class"}
          })
        end
      end

      context "attrib" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "NoT"},
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "attribute"},
            %Tokens.CloseSquare{},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.Attribute{value: "attribute"}
          })
        end
      end

      context "pseudo" do
        it "parses correctly" do
          tokens = [
            %Tokens.Function{value: "NoT"},
            %Tokens.Colon{},
            %Tokens.Colon{},
            %Tokens.Id{value: "first-child"},
            %Tokens.CloseParenthesis{}
          ]

          {_, negation} = Nodes.Negation.parse(State.new(tokens))

          expect(negation) |> to_eq(%Nodes.Negation{
            value: %Nodes.Pseudo{value: "first-child", type: :element}
          })
        end
      end
    end

    context "doesn't have the not function" do
      it "returns nil" do
        tokens = [
          %Tokens.Function{value: "n0t"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "h1"}
        ]

        {_, hash} = Nodes.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end

    context "missing a closing parenthesis" do
      it "returns nil" do
        tokens = [
          %Tokens.Function{value: "not"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "h1"}
        ]

        {_, hash} = Nodes.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end

    context "invalid arg" do
      it "returns nil" do
        tokens = [
          %Tokens.Function{value: "not"},
          %Tokens.Whitespace{},
          %Tokens.Number{value: 42},
          %Tokens.CloseParenthesis{}
        ]

        {_, hash} = Nodes.Negation.parse(State.new(tokens))

        expect(hash) |> to_be_nil
      end
    end
  end
end
