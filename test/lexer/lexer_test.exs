defmodule ExCss.LexerTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.Tokens, as: T
  import TestHelper

  describe "simple.css" do
    it "works correctly" do
      state = ExCss.Lexer.State.new(fixture("simple.css"))

      state
      |> expect_next_token(%T.AtKeyword{value: "charset"}, 7, " ")
      |> expect_next_token(%T.Whitespace{}, 8, "\"")
      |> expect_next_token(%T.String{value: "UTF-8", wrapped_by: "\""}, 15, ";")
      |> expect_next_token(%T.Semicolon{}, 16, " ")
      |> expect_next_token(%T.Whitespace{}, 18, "/")
      |> expect_next_token(%T.Whitespace{}, 58, "h")
      |> expect_next_token(%T.Id{value: "html"}, 62, " ")
      |> expect_next_token(%T.Whitespace{}, 63, "b")
      |> expect_next_token(%T.Id{value: "body"}, 67, " ")
      |> expect_next_token(%T.Whitespace{}, 68, ">")
      |> expect_next_token(%T.Delim{value: ">"}, 69, " ")
      |> expect_next_token(%T.Whitespace{}, 70, "#")
      |> expect_next_token(%T.Hash{value: "container", id: true}, 80, " ")
      |> expect_next_token(%T.Whitespace{}, 81, ".")
      |> expect_next_token(%T.Delim{value: "."}, 82, "c")
      |> expect_next_token(%T.Id{value: "content"}, 89, " ")
      |> expect_next_token(%T.Whitespace{}, 90, "{")
      |> expect_next_token(%T.OpenCurly{}, 91, " ")
      |> expect_next_token(%T.Whitespace{}, 92, "/")
      |> expect_next_token(%T.Whitespace{}, 117, "f")
      |> expect_next_token(%T.Id{value: "font-weight"}, 128, ":")
      |> expect_next_token(%T.Colon{}, 129, " ")
      |> expect_next_token(%T.Whitespace{}, 130, "b")
      |> expect_next_token(%T.Id{value: "bold"}, 134, ";")
      |> expect_next_token(%T.Semicolon{}, 135, "\n")
      |> expect_next_token(%T.Whitespace{}, 138, "f")
      |> expect_next_token(%T.Id{value: "font-size"}, 147, ":")
      |> expect_next_token(%T.Colon{}, 148, " ")
      |> expect_next_token(%T.Whitespace{}, 149, "1")
      |> expect_next_token(%T.Dimension{value: 14, original_value: "14", unit: "px"}, 153, ";")
      |> expect_next_token(%T.Semicolon{}, 154, "\n")
      |> expect_next_token(%T.Whitespace{}, 155, "}")
      |> expect_next_token(%T.CloseCurly{}, 156, "\n")
    end
  end
end
