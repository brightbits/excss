defmodule ExCss.Selectors.Nodes.AttributeTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Selectors.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "just has attribute" do
      it "parses correctly" do
        tokens = [
          %T.OpenSquare{},
          %T.Id{value: "test"},
          %T.CloseSquare{}
        ]

        {_, attribute} = N.Attribute.parse(State.new(tokens))

        expect(attribute) |> to_eq(%N.Attribute{
          value: "test",
          match_token: nil,
          match_value: nil
        })
      end

      context "not closed properly" do
        it "returns nil" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "test"}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end
    end

    context "has match" do
      context "equals" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "test"},
            %T.Whitespace{},
            %T.Delim{value: "="},
            %T.Whitespace{},
            %T.String{value: "cats"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "test",
            match_token: %T.Delim{value: "="},
            match_value: "cats"
          })
        end
      end

      context "prefix match" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "test"},
            %T.Whitespace{},
            %T.PrefixMatch{},
            %T.Id{value: "horses"},
            %T.Whitespace{},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "test",
            match_token: %T.PrefixMatch{},
            match_value: "horses"
          })
        end
      end

      context "suffix match" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.SuffixMatch{},
            %T.Id{value: "carrot"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "batman",
            match_token: %T.SuffixMatch{},
            match_value: "carrot"
          })
        end
      end

      context "substring match" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.SubstringMatch{},
            %T.Id{value: "carrot"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "batman",
            match_token: %T.SubstringMatch{},
            match_value: "carrot"
          })
        end
      end

      context "include match" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.IncludeMatch{},
            %T.Id{value: "carrot"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "batman",
            match_token: %T.IncludeMatch{},
            match_value: "carrot"
          })
        end
      end

      context "dash match" do
        it "parses correctly" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.DashMatch{},
            %T.Id{value: "carrot"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_eq(%N.Attribute{
            value: "batman",
            match_token: %T.DashMatch{},
            match_value: "carrot"
          })
        end
      end

      context "something else" do
        it "returns nil" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.String{value: "something else"},
            %T.Id{value: "carrot"},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end

      context "invalid match value" do
        it "returns nil" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.Delim{value: "="},
            %T.Number{value: 123},
            %T.CloseSquare{}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end

      context "invalid close" do
        it "returns nil" do
          tokens = [
            %T.OpenSquare{},
            %T.Id{value: "batman"},
            %T.Delim{value: "="},
            %T.Id{value: "test"}
          ]

          {_, attribute} = N.Attribute.parse(State.new(tokens))

          expect(attribute) |> to_be_nil
        end
      end
    end
  end
end
