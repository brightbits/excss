defmodule ExCss.Parser.Nodes.SimpleBlockTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "with {" do
      it "parses it correctly" do
        tokens = [
          %T.OpenCurly{},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.Id{value: "test 3"},
          %T.CloseCurly{}
        ]

        {state, simple_block} = N.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%N.SimpleBlock{
          associated_token: %T.OpenCurly{},
          value: {
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.Id{value: "test 3"}
          }
        })

        expect(state.token) |> to_eq(%T.EndOfFile{})
      end
    end

    context "with [" do
      it "parses it correctly" do
        tokens = [
          %T.OpenSquare{},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.Id{value: "test 3"},
          %T.CloseSquare{}
        ]

        {_, simple_block} = N.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%N.SimpleBlock{
          associated_token: %T.OpenSquare{},
          value: {
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.Id{value: "test 3"}
          }
        })
      end
    end

    context "with (" do
      it "parses it correctly" do
        tokens = [
          %T.OpenParenthesis{},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.Id{value: "test 3"},
          %T.CloseParenthesis{}
        ]

        {_, simple_block} = N.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%N.SimpleBlock{
          associated_token: %T.OpenParenthesis{},
          value: {
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.Id{value: "test 3"}
          }
        })
      end
    end

    context "it doesn't close with its mirror" do
      it "just consumes everything and returns it" do
        tokens = [
          %T.OpenParenthesis{},
          %T.Id{value: "test 1"},
          %T.Id{value: "test 2"},
          %T.CloseSquare{},
          %T.CloseCurly{},
          %T.Id{value: "test 3"}
        ]

        {_, simple_block} = N.SimpleBlock.parse(State.new(tokens))

        expect(simple_block) |> to_eq(%N.SimpleBlock{
          associated_token: %T.OpenParenthesis{},
          value: {
            %T.Id{value: "test 1"},
            %T.Id{value: "test 2"},
            %T.CloseSquare{},
            %T.CloseCurly{},
            %T.Id{value: "test 3"}
          }
        })
      end
    end
  end
end
