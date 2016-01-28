defmodule ExCss.Selectors.Nodes.SelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  # selector
  #   : simple_selector_sequence [ combinator simple_selector_sequence ]*
  #   ;
  describe ".parse" do
    context "starts with a simple_selector" do
      context "without a combinator" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"}
          ]

          {_, selector} = N.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.Selector{
            value: %N.SimpleSelector{
              value: %N.TypeSelector{
                value: "h1"
              },
              modifiers: {}
            }
          })
        end
      end

      context "with trailing whitespace but nothing else" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Whitespace{}
          ]

          {_, selector} = N.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.Selector{
            value: %N.SimpleSelector{
              value: %N.TypeSelector{
                value: "h1"
              },
              modifiers: {}
            }
          })
        end
      end

      context "with a whitespace combinator" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Whitespace{},
            %T.Delim{value: "."},
            %T.Id{value: "title"}
          ]

          {_, selector} = N.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.Selector{
            value: %N.Combinator{
              type: :descendant,
              left: %N.SimpleSelector{
                value: %N.TypeSelector{value: "h1"},
                modifiers: {}
              },
              right: %N.SimpleSelector{
                value: %N.UniversalSelector{},
                modifiers: {
                  %N.Class{value: "title"}
                }
              }
            }
          })
        end
      end

      context "with a different combinator" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Whitespace{},
            %T.Delim{value: ">"},
            %T.Whitespace{},
            %T.Delim{value: "."},
            %T.Id{value: "title"}
          ]

          {_, selector} = N.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.Selector{
            value: %N.Combinator{
              type: :child,
              left: %N.SimpleSelector{
                value: %N.TypeSelector{value: "h1"},
                modifiers: {}
              },
              right: %N.SimpleSelector{
                value: %N.UniversalSelector{},
                modifiers: {
                  %N.Class{value: "title"}
                }
              }
            }
          })
        end
      end

      context "with a bunch of combinators" do
        it "parses correctly" do
          tokens = [
            %T.Colon{},
            %T.Function{value: "nth-child"},
            %T.Number{value: 3},
            %T.CloseParenthesis{},
            %T.Whitespace{},
            %T.Delim{value: "."},
            %T.Id{value: "title"},
            %T.Delim{value: "."},
            %T.Id{value: "potato"},
            %T.Hash{value: "my_id"},
            %T.Delim{value: ">"},
            %T.Delim{value: "."},
            %T.Id{value: "cat"}
          ]

          # :nth-child(3) .title.potato#my_id>.cat
          #                comb(descendant)
          #             /                   \
          #   :nth-child(3)             comb(child)
          #                             /            \
          #                    .title.potato#my_id   .cat

          {_, selector} = N.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%N.Selector{
            value: %N.Combinator{
              type: :descendant,
              left: %N.SimpleSelector{
                value: %N.UniversalSelector{},
                modifiers: {
                  %N.Pseudo{
                    type: :function,
                    value: "nth-child",
                    function: {
                      %T.Number{value: 3}
                    }
                  }
                }
              },
              right: %N.Combinator{
                type: :child,
                left: %N.SimpleSelector{
                  value: %N.UniversalSelector{},
                  modifiers: {
                    %N.Class{value: "title"},
                    %N.Class{value: "potato"},
                    %N.Hash{value: "my_id"}
                  }
                },
                right: %N.SimpleSelector{
                  value: %N.UniversalSelector{},
                  modifiers: {
                    %N.Class{value: "cat"}
                  }
                }
              }
            }
          })
        end
      end
    end
  end
end
