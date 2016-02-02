defmodule ExCss.Parser.Nodes.FunctionTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "with a correct ending close parenthesis" do
      it "parses it correctly" do
        tokens = [
          %T.Function{value: "test-123"},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.Id{value: "test 3"},
          %T.CloseParenthesis{}
        ]

        {_, function} = N.Function.parse(State.new(tokens))

        expect(function) |> to_eq(%N.Function{
          name: "test-123",
          value: [
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.Id{value: "test 3"}
          ]
        })
      end
    end

    context "doesn't close" do
      it "just consumes everything and returns it" do
        tokens = [
          %T.Function{value: "test-123"},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.Id{value: "test 3"}
        ]

        {_, simple_block} = N.Function.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%N.Function{
          name: "test-123",
          value: [
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.Id{value: "test 3"}
          ]
        })
      end
    end
  end
end
