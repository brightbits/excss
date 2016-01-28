defmodule ExCss.Parser.Nodes.QualifiedRuleTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

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

        {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens))

        expect(qualified_rule) |> to_be_nil
      end
    end

    context "with {" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Whitespace{},
          %Tokens.Hash{id: true, value: "test"},
          %Tokens.Whitespace{},
          %Tokens.Hash{id: true, value: "test2"},
          %Tokens.Whitespace{},
          %Tokens.OpenCurly{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 2"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 3"},
          %Tokens.Whitespace{},
          %Tokens.CloseCurly{},
          %Tokens.Whitespace{}
        ]

        {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens))

        expect(qualified_rule) |> to_eq(%ExCss.Parser.Nodes.QualifiedRule{
          prelude: {
            %Tokens.Hash{id: true, value: "test"},
            %Tokens.Whitespace{},
            %Tokens.Hash{id: true, value: "test2"},
            %Tokens.Whitespace{}
          },
          block: %Nodes.SimpleBlock{
            associated_token: %Tokens.OpenCurly{},
            value: {
              %Tokens.Id{value: "test 1"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 2"},
              %Tokens.Whitespace{},
              %Tokens.Id{value: "test 3"},
              %Tokens.Whitespace{}
            }
          }
        })
      end
    end
  end
end
