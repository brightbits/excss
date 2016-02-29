defmodule ExCss.Selectors.Nodes.SelectorListTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "single selector" do
      it "parses correctly" do
        tokens = [
          %T.Id{value: "h1"}
        ]

        {_, selector} = N.SelectorList.parse(State.new(tokens))

        expect(selector) |> to_eq(%N.SelectorList{
          value: [
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.TypeSelector{
                  value: "h1"
                },
                modifiers: []
              }
            }
          ]
        })
      end

      context "its invalid" do
        it "returns an empty list of selectors" do
          tokens = [
            %T.OpenParenthesis{}
          ]

          {_, selector} = N.SelectorList.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.SelectorList{value: []})
        end
      end
    end

    context "two selectors" do
      it "parses correctly" do
        tokens = [
          %T.Id{value: "h1"},
          %T.Comma{},
          %T.Delim{value: "."},
          %T.Id{value: "cats"}
        ]

        {_, selector} = N.SelectorList.parse(State.new(tokens))

        expect(selector) |> to_eq(%N.SelectorList{
          value: [
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.TypeSelector{
                  value: "h1"
                },
                modifiers: []
              }
            },
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.UniversalSelector{},
                modifiers: [
                  %N.Class{
                    value: "cats"
                  }
                ]
              }
            }
          ]
        })
      end

      context "with some whitespace" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Whitespace{},
            %T.Comma{},
            %T.Whitespace{},
            %T.Delim{value: "."},
            %T.Id{value: "cats"},
            %T.Whitespace{}
          ]

          {_, selector} = N.SelectorList.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.SelectorList{
            value: [
              %N.Selector{
                value: %N.SimpleSelector{
                  value: %N.TypeSelector{
                    value: "h1"
                  },
                  modifiers: []
                }
              },
              %N.Selector{
                value: %N.SimpleSelector{
                  value: %N.UniversalSelector{},
                  modifiers: [
                    %N.Class{
                      value: "cats"
                    }
                  ]
                }
              }
            ]
          })
        end
      end

      context "one is invalid" do
        it "returns an empty list of selectors" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Comma{},
            %T.CloseParenthesis{}
          ]

          {_, selector} = N.SelectorList.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.SelectorList{value: []})
        end
      end
    end

    context "many selectors" do
      it "parses correctly" do
        tokens = [
          %T.Id{value: "h1"},
          %T.Comma{},
          %T.Delim{value: "."},
          %T.Id{value: "cats"},
          %T.Comma{},
          %T.Id{value: "h1"},
          %T.Delim{value: "."},
          %T.Id{value: "parrot"}
        ]

        {_, selector} = N.SelectorList.parse(State.new(tokens))

        expect(selector) |> to_eq(%N.SelectorList{
          value: [
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.TypeSelector{
                  value: "h1"
                },
                modifiers: []
              }
            },
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.UniversalSelector{},
                modifiers: [
                  %N.Class{
                    value: "cats"
                  }
                ]
              }
            },
            %N.Selector{
              value: %N.SimpleSelector{
                value: %N.TypeSelector{
                  value: "h1"
                },
                modifiers: [
                  %N.Class{
                    value: "parrot"
                  }
                ]
              }
            }
          ]
        })
      end

      context "one is invalid" do
        it "returns an empty list of selectors" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Comma{},
            %T.CloseParenthesis{},
            %T.Comma{},
            %T.Id{value: "h1"},
            %T.Comma{},
            %T.Id{value: "h2"}
          ]

          {_, selector} = N.SelectorList.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.SelectorList{value: []})
        end
      end
    end
  end
end
