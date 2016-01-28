defmodule ExCss.Selectors.Nodes.SimpleSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  #   : [ type_selector | universal ]
  #     [ HASH | class | attrib | pseudo | negation ]*
  #   | [ HASH | class | attrib | pseudo | negation ]+
  #   ;

  # type selector or universal selector followed by 0 or more modifiers or 1 or more modifiers
  describe ".parse" do
    context "starts with a type selector" do
      context "without a modifier" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.TypeSelector{
              value: "h1"
            }
          })
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "h1"},
            %T.Delim{value: "."},
            %T.Id{value: "title"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.TypeSelector{
              value: "h1"
            },
            modifiers: {
              %N.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %T.Id{value: "em"},
            %T.Hash{value: "page_title"},
            %T.OpenSquare{},
            %T.Id{value: "hat"},
            %T.Whitespace{},
            %T.DashMatch{},
            %T.Whitespace{},
            %T.String{value: "cat"},
            %T.CloseSquare{},
            %T.Colon{},
            %T.Id{value: "visited"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.TypeSelector{
              value: "em"
            },
            modifiers: {
              %N.Hash{value: "page_title"},
              %N.Attribute{value: "hat", match_token: %T.DashMatch{}, match_value: "cat"},
              %N.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end

    context "starts with a universal selector" do
      context "without a modifier" do
        it "parses correctly" do
          tokens = [
            %T.Delim{value: "*"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.UniversalSelector{}
          })
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %T.Delim{value: "*"},
            %T.Delim{value: "."},
            %T.Id{value: "title"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.UniversalSelector{},
            modifiers: {
              %N.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %T.Delim{value: "*"},
            %T.Hash{value: "page_title"},
            %T.OpenSquare{},
            %T.Id{value: "hat"},
            %T.Whitespace{},
            %T.DashMatch{},
            %T.Whitespace{},
            %T.String{value: "cat"},
            %T.CloseSquare{},
            %T.Colon{},
            %T.Id{value: "visited"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.UniversalSelector{},
            modifiers: {
              %N.Hash{value: "page_title"},
              %N.Attribute{value: "hat", match_token: %T.DashMatch{}, match_value: "cat"},
              %N.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end

    context "doesn't have a selector" do
      context "without a modifier" do
        it "returns nil" do
          tokens = [
            %T.Number{value: 42}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_be_nil
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %T.Delim{value: "."},
            %T.Id{value: "title"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.UniversalSelector{},
            modifiers: {
              %N.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %T.Hash{value: "page_title"},
            %T.OpenSquare{},
            %T.Id{value: "hat"},
            %T.Whitespace{},
            %T.DashMatch{},
            %T.Whitespace{},
            %T.String{value: "cat"},
            %T.CloseSquare{},
            %T.Colon{},
            %T.Id{value: "visited"}
          ]

          {_, simple_selector} = N.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%N.SimpleSelector{
            value: %N.UniversalSelector{},
            modifiers: {
              %N.Hash{value: "page_title"},
              %N.Attribute{value: "hat", match_token: %T.DashMatch{}, match_value: "cat"},
              %N.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end
  end
end
