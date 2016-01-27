defmodule ExCss.Parser.Nodes.AtRuleTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "with component values" do
      context "that closes with a semicolon" do
        it "parses it correctly" do
          tokens = [
            %Tokens.AtKeyword{value: "test-123"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 1"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 2"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 3"},
            %Tokens.Semicolon{}
          ]

          {_, function} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

          expect(function) |> to_eq(%ExCss.Parser.Nodes.AtRule{
            name: "test-123",
            prelude: [
              %Tokens.Id{value: "test 1"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 2"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 3"}
            ]
          })
        end
      end

      context "that doesn't close with a semicolon" do
        it "parses it correctly" do
          tokens = [
            %Tokens.AtKeyword{value: "test-123"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 1"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 2"},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test 3"}
          ]

          {_, function} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

          expect(function) |> to_eq(%ExCss.Parser.Nodes.AtRule{
            name: "test-123",
            prelude: [
              %Tokens.Id{value: "test 1"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 2"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 3"}
            ]
          })
        end
      end
    end

    context "with a block" do
      it "leaves the prelude empty and sets the block correctly" do
        tokens = [
          %Tokens.AtKeyword{value: "test-123"},
          %Tokens.Whitespace{},
          %Tokens.OpenCurly{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 2"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 3"},
          %Tokens.Whitespace{},
          %Tokens.CloseCurly{}
        ]

        {_, function} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

        expect(function) |> to_eq(%ExCss.Parser.Nodes.AtRule{
          name: "test-123",
          prelude: [],
          block: %Nodes.SimpleBlock{
            associated_token: %Tokens.OpenCurly{},
            value: [
              %Tokens.Id{value: "test 1"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 2"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 3"},
              %Tokens.Whitespace{}
            ]
          }
        })
      end
    end
  end
end
