defmodule ParserTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

  describe ".parse" do
    # it "wut?" do
    #   IO.puts inspect ExCss.Parser.parse("body { background-color: #ffffff; } ")
    # end
    #
    it "parses simple?" do
      result = ExCss.Parser.parse(TestHelper.fixture("github.min.css"))
      result.__struct__.pretty_print(result)
    end
  end
  #
  # describe ".consume_a_list_of_declarations" do
  #   context "declaration list with no declarations in it" do
  #     it "returns no declarations" do
  #       tokens = [
  #         %Tokens.Whitespace{}
  #       ]
  #
  #       {state, declarations} = ExCss.Parser.consume_a_list_of_declarations(State.new(tokens))
  #
  #       expect(declarations) |> to_eq({})
  #     end
  #   end
  #
  #   context "declaration list with single declaration without a semicolon" do
  #     it "parses it correctly" do
  #       tokens = [
  #         %Tokens.Id{value: "font-weight"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "bold"}
  #       ]
  #
  #       {state, declarations} = ExCss.Parser.consume_a_list_of_declarations(State.new(tokens))
  #
  #       expect(declarations) |> to_eq({
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "font-weight",
  #           value: [
  #             %Tokens.Id{value: "bold"}
  #           ]
  #         }
  #       })
  #     end
  #   end
  #
  #   context "declaration list with single declaration with a semicolon" do
  #     it "parses it correctly" do
  #       tokens = [
  #         %Tokens.Id{value: "font-weight"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "bold"},
  #         %Tokens.Semicolon{}
  #       ]
  #
  #       {state, declarations} = ExCss.Parser.consume_a_list_of_declarations(State.new(tokens))
  #
  #       expect(declarations) |> to_eq({
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "font-weight",
  #           value: [
  #             %Tokens.Id{value: "bold"}
  #           ]
  #         }
  #       })
  #     end
  #   end
  #
  #   context "declaration list with multiple declarations" do
  #     it "parses it correctly" do
  #       tokens = [
  #         %Tokens.Id{value: "font-weight"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "bold"},
  #         %Tokens.Semicolon{},
  #         %Tokens.Id{value: "display"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "none"},
  #       ]
  #
  #       {state, declarations} = ExCss.Parser.consume_a_list_of_declarations(State.new(tokens))
  #
  #       expect(declarations) |> to_eq({
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "font-weight",
  #           value: [
  #             %Tokens.Id{value: "bold"}
  #           ]
  #         },
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "display",
  #           value: [
  #             %Tokens.Id{value: "none"}
  #           ]
  #         }
  #       })
  #     end
  #   end
  #
  #   context "with a broken declaration in the middle" do
  #     it "ignores the broken one" do
  #       tokens = [
  #         %Tokens.Id{value: "font-weight"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "bold"},
  #         %Tokens.Semicolon{},
  #         %Tokens.Id{value: "opacity"},
  #         %Tokens.Number{value: 0.1, original_value: "0.1"},
  #         %Tokens.Semicolon{},
  #         %Tokens.Id{value: "display"},
  #         %Tokens.Whitespace{},
  #         %Tokens.Colon{},
  #         %Tokens.Whitespace{},
  #         %Tokens.Id{value: "none"},
  #       ]
  #
  #       {state, declarations} = ExCss.Parser.consume_a_list_of_declarations(State.new(tokens))
  #
  #       expect(declarations) |> to_eq({
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "font-weight",
  #           value: [
  #             %Tokens.Id{value: "bold"}
  #           ]
  #         },
  #         %ExCss.Parser.Nodes.Declaration{
  #           important: false,
  #           name: "display",
  #           value: [
  #             %Tokens.Id{value: "none"}
  #           ]
  #         }
  #       })
  #     end
  #   end
  # end
end
