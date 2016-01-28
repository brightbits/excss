defmodule ExCss.Parser.Nodes.DeclarationTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T

  describe ".parse" do
    context "declaration with single component" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "font-weight"},
          %T.Whitespace{},
          %T.Colon{},
          %T.Whitespace{},
          %T.Id{value: "bold"}
        ]

        {_, declaration} = N.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%N.Declaration{
          important: false,
          name: "font-weight",
          value: {
            %T.Id{value: "bold"}
          }
        })
      end
    end

    context "declaration with single component and no whitespace" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "font-weight"},
          %T.Colon{},
          %T.Id{value: "bold"}
        ]

        {_, declaration} = N.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%N.Declaration{
          important: false,
          name: "font-weight",
          value: {
            %T.Id{value: "bold"}
          }
        })
      end
    end

    context "declaration with single component and !important" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "font-weight"},
          %T.Whitespace{},
          %T.Colon{},
          %T.Whitespace{},
          %T.Id{value: "bold"},
          %T.Whitespace{},
          %T.Delim{value: "!"},
          %T.Id{value: "IMPortant"}
        ]

        {_, declaration} = N.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%N.Declaration{
          important: true,
          name: "font-weight",
          value: {
            %T.Id{value: "bold"},
            %T.Whitespace{}
          }
        })
      end
    end

    context "declaration with multiple components" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "border"},
          %T.Whitespace{},
          %T.Colon{},
          %T.Whitespace{},
          %T.Id{value: "solid"},
          %T.Whitespace{},
          %T.Dimension{value: 1, unit: "px", original_value: "1"},
          %T.Whitespace{},
          %T.Hash{id: false, value: "0f0f0f"}
        ]

        {_, declaration} = N.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%N.Declaration{
          important: false,
          name: "border",
          value: {
            %T.Id{value: "solid"},
            %T.Whitespace{},
            %T.Dimension{value: 1, unit: "px", original_value: "1"},
            %T.Whitespace{},
            %T.Hash{id: false, value: "0f0f0f"}
          }
        })
      end
    end

    context "declaration with multiple components and !important" do
      it "parses it correctly" do
        tokens = [
          %T.Id{value: "border"},
          %T.Whitespace{},
          %T.Colon{},
          %T.Whitespace{},
          %T.Id{value: "solid"},
          %T.Whitespace{},
          %T.Dimension{value: 1, unit: "px", original_value: "1"},
          %T.Whitespace{},
          %T.Hash{id: false, value: "0f0f0f"},
          %T.Whitespace{},
          %T.Delim{value: "!"},
          %T.Id{value: "imPortant"},
          %T.Whitespace{}
        ]

        {_, declaration} = N.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%N.Declaration{
          important: true,
          name: "border",
          value: {
            %T.Id{value: "solid"},
            %T.Whitespace{},
            %T.Dimension{value: 1, unit: "px", original_value: "1"},
            %T.Whitespace{},
            %T.Hash{id: false, value: "0f0f0f"},
            %T.Whitespace{}
          }
        })
      end
    end
  end
end
