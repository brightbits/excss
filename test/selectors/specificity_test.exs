defmodule ExCss.Selectors.SpecificityTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN
  alias ExCss.Lexer.Tokens, as: T

  describe ".visit" do
    it "applys specificity to the stylesheet" do
      stylesheet = ExCss.Parser.parse("""
      @charset "utf-8";
      h1 span#title .big {
        font-weight: bold;
      }
      """)

      stylesheet = ExCss.Selectors.visit(stylesheet)

      expect(stylesheet) |> to_eq(%N.Stylesheet{
        value: %N.RuleList{
          rules: [
            %ExCss.Parser.Nodes.AtRule{
              name: "charset",
              prelude: [%T.String{value: "utf-8", wrapped_by: "\""}],
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
                      %ExCss.Lexer.Tokens.Id{value: "bold"}
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
