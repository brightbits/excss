defmodule ExCss.Parser.Nodes.AttributeTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "just has attribute" do
      it "parses correctly" do
        tokens = [
          %Tokens.OpenSquare{},
          %Tokens.Id{value: "test"},
          %Tokens.CloseSquare{}
        ]

        {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

        expect(attribute) |> to_eq(%Nodes.Attribute{
          value: "test",
          match_token: nil,
          match_value: nil
        })
      end

      context "not closed properly" do
        it "returns nil" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "test"}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end
    end

    context "has match" do
      context "equals" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "test"},
            %Tokens.Whitespace{},
            %Tokens.Delim{value: "="},
            %Tokens.Whitespace{},
            %Tokens.String{value: "cats"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "test",
            match_token: %Tokens.Delim{value: "="},
            match_value: "cats"
          })
        end
      end

      context "prefix match" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "test"},
            %Tokens.Whitespace{},
            %Tokens.PrefixMatch{},
            %Tokens.Id{value: "horses"},
            %Tokens.Whitespace{},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "test",
            match_token: %Tokens.PrefixMatch{},
            match_value: "horses"
          })
        end
      end

      context "suffix match" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.SuffixMatch{},
            %Tokens.Id{value: "carrot"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "batman",
            match_token: %Tokens.SuffixMatch{},
            match_value: "carrot"
          })
        end
      end

      context "substring match" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.SubstringMatch{},
            %Tokens.Id{value: "carrot"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "batman",
            match_token: %Tokens.SubstringMatch{},
            match_value: "carrot"
          })
        end
      end

      context "include match" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.IncludeMatch{},
            %Tokens.Id{value: "carrot"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "batman",
            match_token: %Tokens.IncludeMatch{},
            match_value: "carrot"
          })
        end
      end

      context "dash match" do
        it "parses correctly" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.DashMatch{},
            %Tokens.Id{value: "carrot"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%Nodes.Attribute{
            value: "batman",
            match_token: %Tokens.DashMatch{},
            match_value: "carrot"
          })
        end
      end

      context "something else" do
        it "returns nil" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.String{value: "something else"},
            %Tokens.Id{value: "carrot"},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end

      context "invalid match value" do
        it "returns nil" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.Delim{value: "="},
            %Tokens.Number{value: 123},
            %Tokens.CloseSquare{}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end

      context "invalid close" do
        it "returns nil" do
          tokens = [
            %Tokens.OpenSquare{},
            %Tokens.Id{value: "batman"},
            %Tokens.Delim{value: "="},
            %Tokens.Id{value: "test"}
          ]

          {_, attribute} = Nodes.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end
    end
  end
end
