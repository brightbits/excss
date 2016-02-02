defmodule ExCss.Parser.Nodes.QualifiedRuleTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  # Create a new qualified rule with its prelude initially set to an empty list, and its value initially set to nothing.
  #
  # Repeatedly consume the next input token:
  #
  # <EOF-token>
  # This is a parse error. Return nothing.
  # <{-token>
  # Consume a simple block and assign it to the qualified rule’s block. Return the qualified rule.
  # simple block with an associated token of <{-token>
  # Assign the block to the qualified rule’s block. Return the qualified rule.
  # anything else
  # Reconsume the current input token. Consume a component value. Append the returned value to the qualified rule’s prelude.

  describe ".parse" do
    context "eof is next" do
      it "returns no qualified rule" do
        tokens = []

        {_, qualified_rule} = N.QualifiedRule.parse(State.new(tokens))

        expect(qualified_rule) |> to_be_nil
      end
    end

    context "with {" do
      it "parses it correctly" do
        tokens = [
          %T.Whitespace{},
          %T.Hash{id: true, value: "test"},
          %T.Whitespace{},
          %T.Hash{id: true, value: "test2"},
          %T.Whitespace{},
          %T.OpenCurly{},
          %T.Whitespace{},
          %T.Id{value: "test 1"},
          %T.Whitespace{},
          %T.Id{value: "test 2"},
          %T.Whitespace{},
          %T.Id{value: "test 3"},
          %T.Whitespace{},
          %T.CloseCurly{},
          %T.Whitespace{}
        ]

        {_, qualified_rule} = N.QualifiedRule.parse(State.new(tokens))

        expect(qualified_rule) |> to_eq(%N.QualifiedRule{
          prelude: [
            %T.Hash{id: true, value: "test"},
            %T.Whitespace{},
            %T.Hash{id: true, value: "test2"},
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
