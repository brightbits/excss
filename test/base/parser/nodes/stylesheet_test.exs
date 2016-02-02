defmodule ExCss.Parser.Nodes.StylesheetTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "a few rules" do
      it "parses them correctly" do
        tokens = [
          %T.Whitespace{},
          %T.Hash{id: true, value: "test-123"},
          %T.Whitespace{},
          %T.Id{value: "test 1"},
          %T.Whitespace{},
          %T.Id{value: "test 3"},
          %T.Whitespace{},
          %T.OpenCurly{},
          %T.Id{value: "something"},
          %T.Whitespace{},
          %T.CloseCurly{},
          %T.Whitespace{},
          %T.Hash{id: true, value: "test-123"},
          %T.Whitespace{},
          %T.Delim{value: "."},
          %T.Id{value: "test-1"},
          %T.Comma{},
          %T.Delim{value: "."},
          %T.Id{value: "test 3"},
          %T.Whitespace{},
          %T.OpenCurly{},
          %T.Whitespace{},
          %T.Id{value: "something-else"},
          %T.Whitespace{},
          %T.CloseCurly{},
          %T.Whitespace{}
        ]

        {_, stylesheet} = N.Stylesheet.parse(State.new(tokens))

        expect(stylesheet) |> to_eq(%N.Stylesheet{
          value: %N.RuleList{
            rules: [
              %N.QualifiedRule{
                prelude: [
                  %T.Hash{id: true, value: "test-123"},
                  %T.Whitespace{},
                  %T.Id{value: "test 1"},
                  %T.Whitespace{},
                  %T.Id{value: "test 3"},
                  %T.Whitespace{}
                ],
                block: %N.SimpleBlock{
                  associated_token: %T.OpenCurly{},
                  value: [
                    %T.Id{value: "something"},
                    %T.Whitespace{},
                  ]
                }
              },
              %N.QualifiedRule{
                prelude: [
                  %T.Hash{id: true, value: "test-123"},
                  %T.Whitespace{},
                  %T.Delim{value: "."},
                  %T.Id{value: "test-1"},
                  %T.Comma{},
                  %T.Delim{value: "."},
                  %T.Id{value: "test 3"},
                  %T.Whitespace{}
                ],
                block: %N.SimpleBlock{
                  associated_token: %T.OpenCurly{},
                  value: [
                    %T.Id{value: "something-else"},
                    %T.Whitespace{}
                  ]
                }
              }
            ]
          }
        })
      end
    end
  end
end
