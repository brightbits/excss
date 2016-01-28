defmodule ExCss.Parser.Nodes.PseudoTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "pseudo class" do
      it "parses correctly" do
        tokens = [
          %T.Colon{},
          %T.Id{value: "test"}
        ]

        {_, pseudo} = N.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%N.Pseudo{value: "test", type: :class})
      end

      context "but not an id" do
        it "parses correctly" do
          tokens = [
            %T.Colon{},
            %T.Number{value: 123}
          ]

          {_, pseudo} = N.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end
    end

    context "pseudo element" do
      it "parses correctly" do
        tokens = [
          %T.Colon{},
          %T.Colon{},
          %T.Id{value: "test"}
        ]

        {_, pseudo} = N.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%N.Pseudo{value: "test", type: :element})
      end
    end

    context "pseudo function" do
      it "parses correctly" do
        tokens = [
          %T.Colon{},
          %T.Function{value: "test"},
          %T.Whitespace{},
          %T.Delim{value: "+"},
          %T.Whitespace{},
          %T.Delim{value: "-"},
          %T.Dimension{value: 123, unit: "em"},
          %T.Whitespace{},
          %T.Number{value: 123},
          %T.String{value: "Hello!"},
          %T.Whitespace{},
          %T.Id{value: "testing"},
          %T.CloseParenthesis{}
        ]

        {_, pseudo} = N.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%N.Pseudo{
          value: "test",
          type: :function,
          function: {
            %T.Delim{value: "+"},
            %T.Delim{value: "-"},
            %T.Dimension{value: 123, unit: "em"},
            %T.Number{value: 123},
            %T.String{value: "Hello!"},
            %T.Id{value: "testing"}
          }
        })
      end

      context "with some other token inside the expression" do
        it "returns nil" do
          tokens = [
            %T.Colon{},
            %T.Function{value: "test"},
            %T.DashMatch{},
            %T.CloseParenthesis{}
          ]

          {_, pseudo} = N.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end

      context "without a closing parenthesis" do
        it "returns nil" do
          tokens = [
            %T.Colon{},
            %T.Function{value: "test"},
            %T.Id{value: "test"}
          ]

          {_, pseudo} = N.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end
    end
  end
end
