defmodule ExCss.Parser.Nodes.SimpleSelectorTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

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
            %Tokens.Id{value: "h1"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.TypeSelector{
              value: "h1"
            }
          })
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Id{value: "h1"},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.TypeSelector{
              value: "h1"
            },
            modifiers: {
              %Nodes.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Id{value: "em"},
            %Tokens.Hash{value: "page_title"},
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "hat"},
            %Tokens.Whitespace{},
            %Tokens.DashMatch{},
            %Tokens.Whitespace{},
            %Tokens.String{value: "cat"},
            %Tokens.CloseSquare{},
            %Tokens.Colon{},
            %Tokens.Id{value: "visited"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.TypeSelector{
              value: "em"
            },
            modifiers: {
              %Nodes.Hash{value: "page_title"},
              %Nodes.Attribute{value: "hat", match_token: %Tokens.DashMatch{}, match_value: "cat"},
              %Nodes.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end

    context "starts with a universal selector" do
      context "without a modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Delim{value: "*"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.UniversalSelector{}
          })
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Delim{value: "*"},
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.UniversalSelector{},
            modifiers: {
              %Nodes.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Delim{value: "*"},
            %Tokens.Hash{value: "page_title"},
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "hat"},
            %Tokens.Whitespace{},
            %Tokens.DashMatch{},
            %Tokens.Whitespace{},
            %Tokens.String{value: "cat"},
            %Tokens.CloseSquare{},
            %Tokens.Colon{},
            %Tokens.Id{value: "visited"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.UniversalSelector{},
            modifiers: {
              %Nodes.Hash{value: "page_title"},
              %Nodes.Attribute{value: "hat", match_token: %Tokens.DashMatch{}, match_value: "cat"},
              %Nodes.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end

    context "doesn't have a selector" do
      context "without a modifier" do
        it "returns nil" do
          tokens = [
            %Tokens.Number{value: 42}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_be_nil
        end
      end

      context "with a modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Delim{value: "."},
            %Tokens.Id{value: "title"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.UniversalSelector{},
            modifiers: {
              %Nodes.Class{value: "title"}
            }
          })
        end
      end

      context "with several modifier" do
        it "parses correctly" do
          tokens = [
            %Tokens.Hash{value: "page_title"},
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "hat"},
            %Tokens.Whitespace{},
            %Tokens.DashMatch{},
            %Tokens.Whitespace{},
            %Tokens.String{value: "cat"},
            %Tokens.CloseSquare{},
            %Tokens.Colon{},
            %Tokens.Id{value: "visited"}
          ]

          {_, simple_selector} = Nodes.SimpleSelector.parse(State.new(tokens))

          expect(simple_selector) |> to_eq(%Nodes.SimpleSelector{
            value: %Nodes.UniversalSelector{},
            modifiers: {
              %Nodes.Hash{value: "page_title"},
              %Nodes.Attribute{value: "hat", match_token: %Tokens.DashMatch{}, match_value: "cat"},
              %Nodes.Pseudo{value: "visited", type: :class}
            }
          })
        end
      end
    end
  end
end
