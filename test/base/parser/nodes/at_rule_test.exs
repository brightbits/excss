defmodule ExCss.Parser.Nodes.AtRuleTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "with component values" do
      context "that closes with a semicolon" do
        it "parses it correctly" do
          tokens = [
            %T.AtKeyword{value: "test-123"},
            %T.Whitespace{},
            %T.Id{value: "test 1"},
            %T.Whitespace{},
            %T.Id{value: "test 2"},
            %T.Whitespace{},
            %T.Id{value: "test 3"},
            %T.Semicolon{}
          ]

          {_, function} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

          expect(function) |> to_eq(%ExCss.Parser.Nodes.AtRule{
            name: "test-123",
            prelude: [
              %T.Id{value: "test 1"},
              %T.Whitespace{},
              %T.Id{value: "test 2"},
              %T.Whitespace{},
              %T.Id{value: "test 3"}
            ]
          })
        end
      end

      context "that doesn't close with a semicolon" do
        it "parses it correctly" do
          tokens = [
            %T.AtKeyword{value: "test-123"},
            %T.Whitespace{},
            %T.Id{value: "test 1"},
            %T.Whitespace{},
            %T.Id{value: "test 2"},
            %T.Whitespace{},
            %T.Id{value: "test 3"}
          ]

          {_, rule} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

          expect(rule) |> to_eq(%ExCss.Parser.Nodes.AtRule{
            name: "test-123",
            prelude: [
              %T.Id{value: "test 1"},
              %T.Whitespace{},
              %T.Id{value: "test 2"},
              %T.Whitespace{},
              %T.Id{value: "test 3"}
            ]
          })
        end
      end
    end

    context "with a block" do
      it "leaves the prelude empty and sets the block correctly" do
        tokens = [
          %T.AtKeyword{value: "test-123"},
          %T.Whitespace{},
          %T.OpenCurly{},
          %T.Whitespace{},
          %T.Id{value: "test 1"},
          %T.Whitespace{},
          %T.Id{value: "test 2"},
          %T.Whitespace{},
          %T.Id{value: "test 3"},
          %T.Whitespace{},
          %T.CloseCurly{}
        ]

        {_, rule} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

        expect(rule) |> to_eq(%ExCss.Parser.Nodes.AtRule{
          name: "test-123",
          prelude: [],
          block: %N.SimpleBlock{
            associated_token: %T.OpenCurly{},
            value: [
              %T.Id{value: "test 1"},
              %T.Whitespace{},
              %T.Id{value: "test 2"},
              %T.Whitespace{},
              %T.Id{value: "test 3"},
              %T.Whitespace{}
            ]
          }
        })
      end
    end

    context "with a block and a prelude" do
      it "sets the block and prelude correctly" do
        tokens = [
          %T.AtKeyword{value: "test-123"},
          %T.Whitespace{},
          %T.Id{value: "test A"},
          %T.Whitespace{},
          %T.Id{value: "test B"},
          %T.Whitespace{},
          %T.Dimension{value: 42.5, original_value: "42.5", unit: "rem"},
          %T.Whitespace{},
          %T.OpenCurly{},
          %T.Whitespace{},
          %T.Id{value: "test 1"},
          %T.Whitespace{},
          %T.Id{value: "test 2"},
          %T.Whitespace{},
          %T.Id{value: "test 3"},
          %T.Whitespace{},
          %T.CloseCurly{}
        ]

        {_, rule} = ExCss.Parser.Nodes.AtRule.parse(State.new(tokens))

        expect(rule) |> to_eq(%ExCss.Parser.Nodes.AtRule{
          name: "test-123",
          prelude: [
            %T.Id{value: "test A"},
            %T.Whitespace{},
            %T.Id{value: "test B"},
            %T.Whitespace{},
            %T.Dimension{value: 42.5, original_value: "42.5", unit: "rem"},
            %T.Whitespace{}
          ],
          block: %N.SimpleBlock{
            associated_token: %T.OpenCurly{},
            value: [
              %T.Id{value: "test 1"},
              %T.Whitespace{},
              %T.Id{value: "test 2"},
              %T.Whitespace{},
              %T.Id{value: "test 3"},
              %T.Whitespace{}
            ]
          }
        })
      end
    end
  end
end
