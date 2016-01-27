defmodule ParserTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens
  alias ExCss.Parser.State

  describe ".parse" do
    it "wut?" do
      ExCss.Parser.parse("body { background-color: #ffffff; } ")
    end

    it "parses simple?" do
      result = ExCss.Parser.parse(TestHelper.fixture("simple.css"))
      ExCss.Utils.PrettyPrint.pretty_out(result)
    end
  end
end
