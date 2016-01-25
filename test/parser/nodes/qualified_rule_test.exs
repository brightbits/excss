defmodule ExCss.Parser.Nodes.QualifiedRuleTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

#   Repeatedly consume the next input token:
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

        {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens) |> State.consume)

        expect(qualified_rule) |> to_be_nil
      end
    end
    #
    # context "with {" do
    #   it "parses it correctly" do
    #     tokens = [
    #       %Tokens.OpenCurly{},
    #       %Tokens.Id{value: "test 1"},
    #       %Tokens.Id{value: "test 2"},
    #       %Tokens.Id{value: "test 3"},
    #       %Tokens.CloseCurly{}
    #     ]
    #
    #     {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens) |> State.consume)
    #
    #     expect(qualified_rule) |> to_eq(%ExCss.Parser.Nodes.QualifiedRule{
    #       associated_token: %Tokens.OpenCurly{},
    #       value: [
    #         %Tokens.Id{value: "test 1"},
    #         %Tokens.Id{value: "test 2"},
    #         %Tokens.Id{value: "test 3"}
    #       ]
    #     })
    #   end
    # end
    #
    # context "with [" do
    #   it "parses it correctly" do
    #     tokens = [
    #       %Tokens.OpenSquare{},
    #       %Tokens.Id{value: "test 1"},
    #       %Tokens.Id{value: "test 2"},
    #       %Tokens.Id{value: "test 3"},
    #       %Tokens.CloseSquare{}
    #     ]
    #
    #     {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens) |> State.consume)
    #
    #     expect(qualified_rule) |> to_eq(%ExCss.Parser.Nodes.QualifiedRule{
    #       associated_token: %Tokens.OpenSquare{},
    #       value: [
    #         %Tokens.Id{value: "test 1"},
    #         %Tokens.Id{value: "test 2"},
    #         %Tokens.Id{value: "test 3"}
    #       ]
    #     })
    #   end
    # end
    #
    # context "with (" do
    #   it "parses it correctly" do
    #     tokens = [
    #       %Tokens.OpenParenthesis{},
    #       %Tokens.Id{value: "test 1"},
    #       %Tokens.Id{value: "test 2"},
    #       %Tokens.Id{value: "test 3"},
    #       %Tokens.CloseParenthesis{}
    #     ]
    #
    #     {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens) |> State.consume)
    #
    #     expect(qualified_rule) |> to_eq(%ExCss.Parser.Nodes.QualifiedRule{
    #       associated_token: %Tokens.OpenParenthesis{},
    #       value: [
    #         %Tokens.Id{value: "test 1"},
    #         %Tokens.Id{value: "test 2"},
    #         %Tokens.Id{value: "test 3"}
    #       ]
    #     })
    #   end
    # end
    #
    # context "it doesn't close with its mirror" do
    #   it "just consumes everything and returns it" do
    #     tokens = [
    #       %Tokens.OpenParenthesis{},
    #       %Tokens.Id{value: "test 1"},
    #       %Tokens.Id{value: "test 2"},
    #       %Tokens.CloseSquare{},
    #       %Tokens.CloseCurly{},
    #       %Tokens.Id{value: "test 3"}
    #     ]
    #
    #     {_, qualified_rule} = ExCss.Parser.Nodes.QualifiedRule.parse(State.new(tokens) |> State.consume)
    #
    #     expect(qualified_rule) |> to_eq(%ExCss.Parser.Nodes.QualifiedRule{
    #       associated_token: %Tokens.OpenParenthesis{},
    #       value: [
    #         %Tokens.Id{value: "test 1"},
    #         %Tokens.Id{value: "test 2"},
    #         %Tokens.CloseSquare{},
    #         %Tokens.CloseCurly{},
    #         %Tokens.Id{value: "test 3"}
    #       ]
    #     })
    #   end
    # end
  end
end
