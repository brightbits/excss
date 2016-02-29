defmodule ExCss.ContextTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selectors.Nodes, as: SN

  let(:html) do
    """
      <html>
        <head>
          <style>
            .something { font-weight: bold; }
            h2 {
              color: #fff;
              font-size: 22em;
            }
          </style>

          <title>Test</title>

          <style>
            p { text-decoration: underline; }
          </style>
        </head>

        <body>
          <h1>Something</h1>
          <h2>Something else</h2>

          <p class="something">this is some text</p>
        </body>
      </html>
    """
  end

  describe ".new" do
    it "returns a context with the parsed markup and empty stylesheets" do
      expect(ExCss.Context.new("<html></html>")) |> to_eq(
        %ExCss.Context{
          markup: %ExCss.Markup.Node{
            id: 0,
            tag_name: "html",
            attributes: [],
            children: []
          },
          stylesheets: []
        }
      )
    end

    context "with some style nodes" do
      it "parses each as a stylesheet and adds them to the list of stylesheets" do
        context = ExCss.Context.new(html)

        expect(context.stylesheets) |> to_eq(
          [
            %N.Stylesheet{
              value: %N.RuleList{
                rules: [
                  %SN.StyleRule{
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
                    },
                    selector_list: %SN.SelectorList{
                      value: [
                        %SN.Selector{
                          specificity: 10,
                          value: %SN.SimpleSelector{
                            modifiers: [
                              %SN.Class{value: "something"}
                            ],
                            value: %SN.UniversalSelector{}
                          }
                        }
                      ]
                    }
                  },
                  %SN.StyleRule{
                    declarations: %N.DeclarationList{
                      value: [
                        %N.Declaration{
                          important: false,
                          name: "color",
                          value: [
                            %ExCss.Lexer.Tokens.Hash{id: true, value: "fff"}
                          ]
                        },
                        %N.Declaration{
                          important: false,
                          name: "font-size",
                          value: [
                            %ExCss.Lexer.Tokens.Dimension{
                              original_value: "22",
                              unit: "em",
                              value: 22.0
                            }
                          ]
                        }
                      ]
                    },
                    selector_list: %SN.SelectorList{
                      value: [
                        %SN.Selector{
                          specificity: 1,
                          value: %SN.SimpleSelector{
                            modifiers: [],
                            value: %SN.TypeSelector{value: "h2"}
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            },
            %N.Stylesheet{
              value: %N.RuleList{
                rules: [
                  %SN.StyleRule{
                    declarations: %N.DeclarationList{
                      value: [
                        %N.Declaration{
                          important: false,
                          name: "text-decoration",
                          value: [
                            %ExCss.Lexer.Tokens.Id{value: "underline"}
                          ]
                        }
                      ]
                    },
                    selector_list: %SN.SelectorList{
                      value: [
                        %SN.Selector{
                          specificity: 1,
                          value: %SN.SimpleSelector{
                            modifiers: [],
                            value: %SN.TypeSelector{value: "p"}
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        )
      end
    end
  end
end
