defmodule ExCss.Parser.Nodes.PseudoTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "pseudo class" do
      it "parses correctly" do
        tokens = [
          %Tokens.Colon{},
          %Tokens.Id{value: "test"}
        ]

        {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%Nodes.Pseudo{value: "test", type: :class})
      end

      context "but not an id" do
        it "parses correctly" do
          tokens = [
            %Tokens.Colon{},
            %Tokens.Number{value: 123}
          ]

          {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end
    end

    context "pseudo element" do
      it "parses correctly" do
        tokens = [
          %Tokens.Colon{},
          %Tokens.Colon{},
          %Tokens.Id{value: "test"}
        ]

        {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%Nodes.Pseudo{value: "test", type: :element})
      end
    end

    context "pseudo function" do
      it "parses correctly" do
        tokens = [
          %Tokens.Colon{},
          %Tokens.Function{value: "test"},
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "+"},
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "-"},
          %Tokens.Dimension{value: 123, unit: "em"},
          %Tokens.Whitespace{},
          %Tokens.Number{value: 123},
          %Tokens.String{value: "Hello!"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "testing"},
          %Tokens.CloseParenthesis{}
        ]

        {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

        expect(pseudo) |> to_eq(%Nodes.Pseudo{
          value: "test",
          type: :function,
          function: [
            %Tokens.Delim{value: "+"},
            %Tokens.Delim{value: "-"},
            %Tokens.Dimension{value: 123, unit: "em"},
            %Tokens.Number{value: 123},
            %Tokens.String{value: "Hello!"},
            %Tokens.Id{value: "testing"}
          ]
        })
      end

      context "with some other token inside the expression" do
        it "returns nil" do
          tokens = [
            %Tokens.Colon{},
            %Tokens.Function{value: "test"},
            %Tokens.DashMatch{},
            %Tokens.CloseParenthesis{}
          ]

          {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end

      context "without a closing parenthesis" do
        it "returns nil" do
          tokens = [
            %Tokens.Colon{},
            %Tokens.Function{value: "test"},
            %Tokens.Id{value: "test"}
          ]

          {_, pseudo} = Nodes.Pseudo.parse(State.new(tokens))

          expect(pseudo) |> to_be_nil
        end
      end
    end
  end
end
