defmodule ExCss.Parser.Nodes.SimpleBlockTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

  describe ".parse" do
    context "with {" do
      it "parses it correctly" do
        tokens = [
          %Tokens.OpenCurly{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.Id{value: "test 3"},
          %Tokens.CloseCurly{}
        ]

        {state, simple_block} = ExCss.Parser.Nodes.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%ExCss.Parser.Nodes.SimpleBlock{
          associated_token: %Tokens.OpenCurly{},
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.Id{value: "test 3"}
          }
        })

        expect(state.token) |> to_eq(%Tokens.EndOfFile{})
      end
    end

    context "with [" do
      it "parses it correctly" do
        tokens = [
          %Tokens.OpenSquare{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.Id{value: "test 3"},
          %Tokens.CloseSquare{}
        ]

        {_, simple_block} = ExCss.Parser.Nodes.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%ExCss.Parser.Nodes.SimpleBlock{
          associated_token: %Tokens.OpenSquare{},
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.Id{value: "test 3"}
          }
        })
      end
    end

    context "with (" do
      it "parses it correctly" do
        tokens = [
          %Tokens.OpenParenthesis{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.Id{value: "test 3"},
          %Tokens.CloseParenthesis{}
        ]

        {_, simple_block} = ExCss.Parser.Nodes.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%ExCss.Parser.Nodes.SimpleBlock{
          associated_token: %Tokens.OpenParenthesis{},
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.Id{value: "test 3"}
          }
        })
      end
    end

    context "it doesn't close with its mirror" do
      it "just consumes everything and returns it" do
        tokens = [
          %Tokens.OpenParenthesis{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Id{value: "test 2"},
          %Tokens.CloseSquare{},
          %Tokens.CloseCurly{},
          %Tokens.Id{value: "test 3"}
        ]

        {_, simple_block} = ExCss.Parser.Nodes.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%ExCss.Parser.Nodes.SimpleBlock{
          associated_token: %Tokens.OpenParenthesis{},
          value: {
            %Tokens.Id{value: "test 1"},
            %Tokens.Id{value: "test 2"},
            %Tokens.CloseSquare{},
            %Tokens.CloseCurly{},
            %Tokens.Id{value: "test 3"}
          }
        })
      end
    end
  end
end
