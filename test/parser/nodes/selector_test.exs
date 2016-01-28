defmodule ExCss.Parser.Nodes.SelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  # selector
  #   : simple_selector_sequence [ combinator simple_selector_sequence ]*
  #   ;
  describe ".parse" do
    context "starts with a simple_selector" do
      context "without a combinator" do
        it "parses correctly" do
          tokens = [
            %Tokens.Id{value: "h1"}
          ]

          {_, selector} = Nodes.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%Nodes.Selector{
            value: %Nodes.SimpleSelector{
              value: %Nodes.TypeSelector{
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
            %Tokens.Id{value: "h1"},
            %Tokens.Whitespace{}
          ]

          {_, selector} = Nodes.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%Nodes.Selector{
            value: %Nodes.SimpleSelector{
              value: %Nodes.TypeSelector{
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
            %Tokens.Id{value: "h1"},
            %Tokens.Whitespace{},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"}
          ]

          {_, selector} = Nodes.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%Nodes.Selector{
            value: %Nodes.Combinator{
              type: :descendant,
              left: %Nodes.SimpleSelector{
                value: %Nodes.TypeSelector{value: "h1"},
                modifiers: {}
              },
              right: %Nodes.SimpleSelector{
                value: %Nodes.UniversalSelector{},
                modifiers: {
                  %Nodes.Class{value: "title"}
                }
              }
            }
          })
        end
      end

      context "with a different combinator" do
        it "parses correctly" do
          tokens = [
            %Tokens.Id{value: "h1"},
            %Tokens.Whitespace{},
            %Tokens.Delim{value: ">"},
            %Tokens.Whitespace{},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"}
          ]

          {_, selector} = Nodes.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%Nodes.Selector{
            value: %Nodes.Combinator{
              type: :child,
              left: %Nodes.SimpleSelector{
                value: %Nodes.TypeSelector{value: "h1"},
                modifiers: {}
              },
              right: %Nodes.SimpleSelector{
                value: %Nodes.UniversalSelector{},
                modifiers: {
                  %Nodes.Class{value: "title"}
                }
              }
            }
          })
        end
      end

      context "with a bunch of combinators" do
        it "parses correctly" do
          tokens = [
            %Tokens.Colon{},
            %Tokens.Function{value: "nth-child"},
            %Tokens.Number{value: 3},
            %Tokens.CloseParenthesis{},
            %Tokens.Whitespace{},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "potato"},
            %Tokens.Hash{value: "my_id"},
            %Tokens.Delim{value: ">"},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "cat"}
          ]

          # :nth-child(3) .title.potato#my_id>.cat
          #                comb(descendant)
          #             /                   \
          #   :nth-child(3)             comb(child)
          #                             /            \
          #                    .title.potato#my_id   .cat

          {_, selector} = Nodes.Selector.parse(State.new(tokens))

          expect(selector) |> to_eq(%Nodes.Selector{
            value: %Nodes.Combinator{
              type: :descendant,
              left: %Nodes.SimpleSelector{
                value: %Nodes.UniversalSelector{},
                modifiers: {
                  %Nodes.Pseudo{
                    type: :function,
                    value: "nth-child",
                    function: {
                      %Tokens.Number{value: 3}
                    }
                  }
                }
              },
              right: %Nodes.Combinator{
                type: :child,
                left: %Nodes.SimpleSelector{
                  value: %Nodes.UniversalSelector{},
                  modifiers: {
                    %Nodes.Class{value: "title"},
                    %Nodes.Class{value: "potato"},
                    %Nodes.Hash{value: "my_id"}
                  }
                },
                right: %Nodes.SimpleSelector{
                  value: %Nodes.UniversalSelector{},
                  modifiers: {
                    %Nodes.Class{value: "cat"}
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
