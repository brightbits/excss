defmodule ExCss.SelectorsTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN
  alias ExCss.Lexer.Tokens, as: T

  describe ".visit" do
    it "transforms qualified rules in to style rules with selectors and declaration lists" do
      stylesheet = %N.Stylesheet{
        value: %N.RuleList{
          rules: [
            %ExCss.Parser.Nodes.AtRule{
              name: "charset",
              prelude: [%T.String{value: "utf-8"}],
              block: nil
            },
            %ExCss.Parser.Nodes.QualifiedRule{
              prelude: [
                %T.Id{value: "h1"},
                %T.Whitespace{},
                %T.Id{value: "span"},
                %T.Hash{value: "title"},
                %T.Whitespace{},
                %T.Delim{value: "."},
                %T.Id{value: "big"},
                %T.Whitespace{}
              ],
              block: %N.SimpleBlock{
                associated_token: %T.OpenCurly{},
                value: [
                  %T.Id{value: "font-weight"},
                  %T.Colon{},
                  %T.Whitespace{},
                  %T.Id{value: "bold"},
                  %T.Whitespace{},
                  %T.Semicolon{}
                ]
              }
            }
          ]
        }
      }

      stylesheet = ExCss.Selectors.visit(stylesheet)

      expect(stylesheet) |> to_eq(%N.Stylesheet{
        value: %N.RuleList{
          rules: [
            %ExCss.Parser.Nodes.AtRule{
              name: "charset",
              prelude: [%T.String{value: "utf-8"}],
              block: nil
            },
            %SN.StyleRule{
              selector_list: %SN.SelectorList{
                value: [
                  %SN.Selector{
                    specificity: 112,
                    value: %SN.Combinator{
                      type: :descendant,
                      left: %SN.SimpleSelector{
                        value: %SN.TypeSelector{value: "h1"},
                        modifiers: []
                      },
                      right: %SN.Combinator{
                        type: :descendant,
                        left: %SN.SimpleSelector{
                          value: %SN.TypeSelector{value: "span"},
                          modifiers: [
                            %SN.Hash{value: "title"}
                          ]
                        },
                        right: %SN.SimpleSelector{
                          value: %SN.UniversalSelector{},
                          modifiers: [
                            %SN.Class{value: "big"}
                          ]
                        }
                      }
                    }
                  }
                ]
              },
              declarations: %N.DeclarationList{
                value: [
                  %N.Declaration{
                    important: false,
                    name: "font-weight",
                    value: [
                      %ExCss.Lexer.Tokens.Id{value: "bold"},
                      %ExCss.Lexer.Tokens.Whitespace{}
                    ]
                  }
                ]
              }
            }
          ]
        }
      })
    end
  end
end
