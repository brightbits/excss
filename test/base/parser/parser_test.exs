defmodule ParserTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    it "parses simple?" do
      result = ExCss.Parser.parse(TestHelper.fixture("simple1.css"))

      expect(result) |> to_eq(%N.Stylesheet{
        value: %N.RuleList{
          rules: [
            %N.AtRule{
              prelude: [
                %T.String{value: "UTF-8", wrapped_by: "\""}
              ],
              name: "charset",
              block: nil
            },
            %N.QualifiedRule{
              prelude: [
                %T.Id{value: "html"},
                %T.Whitespace{},
                %T.Id{value: "body"},
                %T.Whitespace{},
                %T.Delim{value: ">"},
                %T.Whitespace{},
                %T.Hash{value: "container", id: true},
                %T.Whitespace{},
                %T.Delim{value: "."},
                %T.Id{value: "content"},
                %T.Whitespace{}
              ],
              block: %N.SimpleBlock{
                associated_token: %T.OpenCurly{},
                value: [
                  %T.Whitespace{},
                  %T.Id{value: "font-weight"},
                  %T.Colon{},
                  %T.Whitespace{},
                  %T.Id{value: "bold"},
                  %T.Semicolon{},
                  %T.Whitespace{},
                  %T.Id{value: "font-size"},
                  %T.Colon{},
                  %T.Whitespace{},
                  %T.Dimension{original_value: "14", unit: "px", value: 14.0},
                  %T.Semicolon{},
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
