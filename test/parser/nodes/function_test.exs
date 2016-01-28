defmodule ExCss.Parser.Nodes.FunctionTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

  describe ".parse" do
    context "with a correct ending close parenthesis" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Function{value: "test-123"},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.Id{value: "test 3"},
          %Tokens.CloseParenthesis{}
        ]

        {_, function} = ExCss.Parser.Nodes.Function.parse(State.new(tokens))

        expect(function) |> to_eq(%ExCss.Parser.Nodes.Function{
          name: "test-123",
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.Id{value: "test 3"}
          }
        })
      end
    end

    context "doesn't close" do
      it "just consumes everything and returns it" do
        tokens = [
          %Tokens.Function{value: "test-123"},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.Id{value: "test 3"}
        ]

        {_, simple_block} = ExCss.Parser.Nodes.Function.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%ExCss.Parser.Nodes.Function{
          name: "test-123",
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.Id{value: "test 3"}
          }
        })
      end
    end
  end
end
