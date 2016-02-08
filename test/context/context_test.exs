defmodule ExCss.ContextTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Selector.Nodes, as: SN

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
          markup: {"html", [excss_id: 0], []},
          stylesheets: []
        }
      )
    end

    context "with some style nodes" do
      it "parses each as a stylesheet and adds them to the list of stylesheets" do
        context = ExCss.Context.new(html)

        expect(context.stylesheets) |> to_eq(
          [
            %ExCss.Parser.Nodes.Stylesheet{
              value: %ExCss.Parser.Nodes.RuleList{
                rules: [
                  %ExCss.Selectors.Nodes.StyleRule{
                    declarations: %ExCss.Parser.Nodes.DeclarationList{
                      value: [
                        %ExCss.Parser.Nodes.Declaration{
                          important: false,
                          name: "font-weight",
                          value: [
                            %ExCss.Lexer.Tokens.Id{value: "bold"}
                          ]
                        }
                      ]
                    },
                    selector: %ExCss.Selectors.Nodes.Selector{
                      specificity: 10,
                      value: %ExCss.Selectors.Nodes.SimpleSelector{
                        modifiers: [
                          %ExCss.Selectors.Nodes.Class{value: "something"}
                        ],
                        value: %ExCss.Selectors.Nodes.UniversalSelector{}
                      }
                    }
                  },
                  %ExCss.Selectors.Nodes.StyleRule{
                    declarations: %ExCss.Parser.Nodes.DeclarationList{
                      value: [
                        %ExCss.Parser.Nodes.Declaration{
                          important: false,
                          name: "color",
                          value: [
                            %ExCss.Lexer.Tokens.Hash{id: true, value: "fff"}
                          ]
                        },
                        %ExCss.Parser.Nodes.Declaration{
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
                    selector: %ExCss.Selectors.Nodes.Selector{
                      specificity: 1,
                      value: %ExCss.Selectors.Nodes.SimpleSelector{
                        modifiers: [],
                        value: %ExCss.Selectors.Nodes.TypeSelector{value: "h2"}
                      }
                    }
                  }
                ]
              }
            },
            %ExCss.Parser.Nodes.Stylesheet{
              value: %ExCss.Parser.Nodes.RuleList{
                rules: [
                  %ExCss.Selectors.Nodes.StyleRule{
                    declarations: %ExCss.Parser.Nodes.DeclarationList{
                      value: [
                        %ExCss.Parser.Nodes.Declaration{
                          important: false,
                          name: "text-decoration",
                          value: [
                            %ExCss.Lexer.Tokens.Id{value: "underline"}
                          ]
                        }
                      ]
                    },
                    selector: %ExCss.Selectors.Nodes.Selector{
                      specificity: 1,
                      value: %ExCss.Selectors.Nodes.SimpleSelector{
                        modifiers: [],
                        value: %ExCss.Selectors.Nodes.TypeSelector{value: "p"}
                      }
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
