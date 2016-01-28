defmodule ExCss.Parser.Nodes.RuleListTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "a few rules" do
      it "parses them correctly" do
        tokens = [
          %Tokens.AtKeyword{value: "charset"},
          %Tokens.Whitespace{},
          %Tokens.OpenCurly{},
          %Tokens.Id{value: "Hey!"},
          %Tokens.CloseCurly{},
          %Tokens.Whitespace{},
          %Tokens.Hash{id: true, value: "test-123"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 1"},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "test 3"},
          %Tokens.Whitespace{},
          %Tokens.OpenCurly{},
          %Tokens.Id{value: "something"},
          %Tokens.Whitespace{},
          %Tokens.CloseCurly{},
          %Tokens.Whitespace{},
          %Tokens.Hash{id: true, value: "test-123"},
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "."},
          %Tokens.Id{value: "test-1"},
          %Tokens.Comma{},
          %Tokens.Delim{value: "."},
          %Tokens.Id{value: "test 3"},
          %Tokens.Whitespace{},
          %Tokens.OpenCurly{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "something-else"},
          %Tokens.Whitespace{},
          %Tokens.CloseCurly{},
          %Tokens.Whitespace{}
        ]

        {_, rule_list} = ExCss.Parser.Nodes.RuleList.parse(State.new(tokens))

        expect(rule_list) |> to_eq(%Nodes.RuleList{
          rules: {
            %Nodes.AtRule{
              name: "charset",
              prelude: {},
              block: %Nodes.SimpleBlock{
                associated_token: %Tokens.OpenCurly{},
                value: {
                  %Tokens.Id{value: "Hey!"}
                }
              }
            },
            %Nodes.QualifiedRule{
              prelude: {
                %Tokens.Hash{id: true, value: "test-123"},
                %Tokens.Whitespace{},
                %Tokens.Id{value: "test 1"},
                %Tokens.Whitespace{},
                %Tokens.Id{value: "test 3"},
                %Tokens.Whitespace{}
              },
              block: %Nodes.SimpleBlock{
                associated_token: %Tokens.OpenCurly{},
                value: {
                  %Tokens.Id{value: "something"},
                  %Tokens.Whitespace{},
                }
              }
            },
            %Nodes.QualifiedRule{
              prelude: {
                %Tokens.Hash{id: true, value: "test-123"},
                %Tokens.Whitespace{},
                %Tokens.Delim{value: "."},
                %Tokens.Id{value: "test-1"},
                %Tokens.Comma{},
                %Tokens.Delim{value: "."},
                %Tokens.Id{value: "test 3"},
                %Tokens.Whitespace{}
              },
              block: %Nodes.SimpleBlock{
                associated_token: %Tokens.OpenCurly{},
                value: {
                  %Tokens.Id{value: "something-else"},
                  %Tokens.Whitespace{}
                }
              }
            }
          }
        })
      end
    end
  end
end
