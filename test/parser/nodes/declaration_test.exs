defmodule ExCss.Parser.Nodes.DeclarationTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

  describe ".parse" do
    context "declaration with single component" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "font-weight"},
          %Tokens.Whitespace{},
          %Tokens.Colon{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "bold"}
        ]

        {_, declaration} = ExCss.Parser.Nodes.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%ExCss.Parser.Nodes.Declaration{
          important: false,
          name: "font-weight",
          value: [
            %Tokens.Id{value: "bold"}
          ]
        })
      end
    end

    context "declaration with single component and no whitespace" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "font-weight"},
          %Tokens.Colon{},
          %Tokens.Id{value: "bold"}
        ]

        {_, declaration} = ExCss.Parser.Nodes.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%ExCss.Parser.Nodes.Declaration{
          important: false,
          name: "font-weight",
          value: [
            %Tokens.Id{value: "bold"}
          ]
        })
      end
    end

    context "declaration with single component and !important" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "font-weight"},
          %Tokens.Whitespace{},
          %Tokens.Colon{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "bold"},
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "!"},
          %Tokens.Id{value: "IMPortant"}
        ]

        {_, declaration} = ExCss.Parser.Nodes.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%ExCss.Parser.Nodes.Declaration{
          important: true,
          name: "font-weight",
          value: [
            %Tokens.Id{value: "bold"},
            %Tokens.Whitespace{}
          ]
        })
      end
    end

    context "declaration with multiple components" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "border"},
          %Tokens.Whitespace{},
          %Tokens.Colon{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "solid"},
          %Tokens.Whitespace{},
          %Tokens.Dimension{value: 1, unit: "px", original_value: "1"},
          %Tokens.Whitespace{},
          %Tokens.Hash{id: false, value: "0f0f0f"}
        ]

        {_, declaration} = ExCss.Parser.Nodes.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%ExCss.Parser.Nodes.Declaration{
          important: false,
          name: "border",
          value: [
            %Tokens.Id{value: "solid"},
            %Tokens.Whitespace{},
            %Tokens.Dimension{value: 1, unit: "px", original_value: "1"},
            %Tokens.Whitespace{},
            %Tokens.Hash{id: false, value: "0f0f0f"}
          ]
        })
      end
    end

    context "declaration with multiple components and !important" do
      it "parses it correctly" do
        tokens = [
          %Tokens.Id{value: "border"},
          %Tokens.Whitespace{},
          %Tokens.Colon{},
          %Tokens.Whitespace{},
          %Tokens.Id{value: "solid"},
          %Tokens.Whitespace{},
          %Tokens.Dimension{value: 1, unit: "px", original_value: "1"},
          %Tokens.Whitespace{},
          %Tokens.Hash{id: false, value: "0f0f0f"},
          %Tokens.Whitespace{},
          %Tokens.Delim{value: "!"},
          %Tokens.Id{value: "imPortant"},
          %Tokens.Whitespace{}
        ]

        {_, declaration} = ExCss.Parser.Nodes.Declaration.parse(State.new(tokens))

        expect(declaration) |> to_eq(%ExCss.Parser.Nodes.Declaration{
          important: true,
          name: "border",
          value: [
            %Tokens.Id{value: "solid"},
            %Tokens.Whitespace{},
            %Tokens.Dimension{value: 1, unit: "px", original_value: "1"},
            %Tokens.Whitespace{},
            %Tokens.Hash{id: false, value: "0f0f0f"},
            %Tokens.Whitespace{}
          ]
        })
      end
    end
  end
end
