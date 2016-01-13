defmodule ParserTest do
  use Pavlov.Case, async: true

  import Pavlov.Syntax.Expect

  describe ".parse" do
    it "wut?" do
      IO.puts inspect ExCss.Parser.parse("body { background-color: #ffffff; } ")
    end

    it "parses github?" do
       IO.puts inspect ExCss.Parser.parse(TestHelper.fixture("github.min.css"))
    end
  end
end
