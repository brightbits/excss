defmodule ExCss.Parser.Nodes.DeclarationListTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes

  describe ".parse" do
    context "single declaration" do
      context "without a semicolon" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Whitespace{},
            %Tokens.Colon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "bold"}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              }
            ]
          })
        end
      end

      context "with a semicolon" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Whitespace{},
            %Tokens.Colon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "bold"},
            %Tokens.Semicolon{}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              }
            ]
          })
        end
      end

      context "with an invalid declaration" do
        it "parses ignores it and still consumes up to the eof" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Semicolon{}
          ]

          {state, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: []
          })

          expect(state.token) |> to_eq(%Tokens.EndOfFile{})
        end
      end
    end

    context "at rules" do
      context "single at rule" do
        it "parses it correctly" do
          tokens = [
            %Tokens.AtKeyword{value: "font-face"},
            %Tokens.Whitespace{},
            %Tokens.OpenCurly{},
            %Tokens.Colon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test"},
            %Tokens.CloseCurly{}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.AtRule{
                name: "font-face",
                prelude: [],
                block: %Nodes.SimpleBlock{
                  associated_token: %Tokens.OpenCurly{},
                  value: [
                    %Tokens.Colon{},
                    %Tokens.Whitespace{},
                    %Tokens.Id{value: "test"}
                  ]
                }
              }
            ]
          })
        end
      end

      context "with declarations around it" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Whitespace{},
            %Tokens.Id{value: "cat"},
            %Tokens.Colon{},
            %Tokens.Number{value: 4, original_value: "4"},
            %Tokens.Semicolon{},
            %Tokens.AtKeyword{value: "font-face"},
            %Tokens.Whitespace{},
            %Tokens.OpenCurly{},
            %Tokens.Colon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "test"},
            %Tokens.CloseCurly{},
            %Tokens.Id{value: "dog"},
            %Tokens.Colon{},
            %Tokens.Number{value: 5, original_value: "5"},
            %Tokens.Delim{value: "!"},
            %Tokens.Id{value: "IMPORTANT"}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "cat",
                value: [
                  %Tokens.Number{value: 4, original_value: "4"}
                ]
              },
              %Nodes.AtRule{
                name: "font-face",
                prelude: [],
                block: %Nodes.SimpleBlock{
                  associated_token: %Tokens.OpenCurly{},
                  value: [
                    %Tokens.Colon{},
                    %Tokens.Whitespace{},
                    %Tokens.Id{value: "test"}
                  ]
                }
              },
              %Nodes.Declaration{
                important: true,
                name: "dog",
                value: [
                  %Tokens.Number{value: 5, original_value: "5"}
                ]
              }
            ]
          })
        end
      end
    end

    context "multiple declarations" do
      context "without a semicolon at the end" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Colon{},
            %Tokens.Id{value: "bold"},
            %Tokens.Semicolon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "font-size"},
            %Tokens.Colon{},
            %Tokens.Dimension{value: 12, original_value: "12", unit: "px"}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              },
              %Nodes.Declaration{
                important: false,
                name: "font-size",
                value: [
                  %Tokens.Dimension{value: 12, original_value: "12", unit: "px"}
                ]
              }
            ]
          })
        end
      end

      context "with a semicolon at the end" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Colon{},
            %Tokens.Id{value: "bold"},
            %Tokens.Semicolon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "font-size"},
            %Tokens.Colon{},
            %Tokens.Dimension{value: 12, original_value: "12", unit: "px"},
            %Tokens.Semicolon{}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              },
              %Nodes.Declaration{
                important: false,
                name: "font-size",
                value: [
                  %Tokens.Dimension{value: 12, original_value: "12", unit: "px"}
                ]
              }
            ]
          })
        end
      end

      context "with some extra semicolon" do
        it "parses it correctly" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Colon{},
            %Tokens.Id{value: "bold"},
            %Tokens.Semicolon{},
            %Tokens.Semicolon{},
            %Tokens.Semicolon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "font-size"},
            %Tokens.Colon{},
            %Tokens.Dimension{value: 12, original_value: "12", unit: "px"},
            %Tokens.Semicolon{}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              },
              %Nodes.Declaration{
                important: false,
                name: "font-size",
                value: [
                  %Tokens.Dimension{value: 12, original_value: "12", unit: "px"}
                ]
              }
            ]
          })
        end
      end

      context "with an invalid declaration" do
        it "parses ignores it and still consumes up to the eof" do
          tokens = [
            %Tokens.Id{value: "font-weight"},
            %Tokens.Colon{},
            %Tokens.Id{value: "bold"},
            %Tokens.Semicolon{},
            %Tokens.Whitespace{},
            %Tokens.Id{value: "font-size"},
            %Tokens.Dimension{value: 12, original_value: "12", unit: "px"},
            %Tokens.Semicolon{},
            %Tokens.Id{value: "border"},
            %Tokens.Colon{},
            %Tokens.Id{value: "solid"},
            %Tokens.Dimension{value: 1, original_value: "1", unit: "px"},
            %Tokens.Hash{value: "ff0000"}
          ]

          {_, declaration_list} = Nodes.DeclarationList.parse(State.new(tokens))

          expect(declaration_list) |> to_eq(%Nodes.DeclarationList{
            value: [
              %Nodes.Declaration{
                important: false,
                name: "font-weight",
                value: [
                  %Tokens.Id{value: "bold"}
                ]
              },
              %Nodes.Declaration{
                important: false,
                name: "border",
                value: [
                  %Tokens.Id{value: "solid"},
                  %Tokens.Dimension{value: 1, unit: "px", original_value: "1"},
                  %Tokens.Hash{value: "ff0000"}
                ]
              }
            ]
          })
        end
      end
    end
  end
end
