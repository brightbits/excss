defmodule ExCss.LexerTest do
  use Pavlov.Case, async: true
  
  alias ExCss.Lexer.Tokens, as: T
  import TestHelper

  describe "simple.css" do
    it "works correctly" do
      state = ExCss.Lexer.State.new(fixture("simple1.css"))

      state
      |> expect_next_token(%T.AtKeyword{value: "charset"}, 7, " ")
      |> expect_next_token(%T.Whitespace{}, 8, "\"")
      |> expect_next_token(%T.String{value: "UTF-8", wrapped_by: "\""}, 15, ";")
      |> expect_next_token(%T.Semicolon{}, 16, "\n")
      |> expect_next_token(%T.Whitespace{}, 18, "h")
      |> expect_next_token(%T.Id{value: "html"}, 22, " ")
      |> expect_next_token(%T.Whitespace{}, 23, "b")
      |> expect_next_token(%T.Id{value: "body"}, 27, " ")
      |> expect_next_token(%T.Whitespace{}, 28, ">")
      |> expect_next_token(%T.Delim{value: ">"}, 29, " ")
      |> expect_next_token(%T.Whitespace{}, 30, "#")
      |> expect_next_token(%T.Hash{value: "container", id: true}, 40, " ")
      |> expect_next_token(%T.Whitespace{}, 41, ".")
      |> expect_next_token(%T.Delim{value: "."}, 42, "c")
      |> expect_next_token(%T.Id{value: "content"}, 49, " ")
      |> expect_next_token(%T.Whitespace{}, 50, "{")
      |> expect_next_token(%T.OpenCurly{}, 51, " ")
      |> expect_next_token(%T.Whitespace{}, 52, "/")
      |> expect_next_token(%T.Whitespace{}, 77, "f")
      |> expect_next_token(%T.Id{value: "font-weight"}, 88, ":")
      |> expect_next_token(%T.Colon{}, 89, " ")
      |> expect_next_token(%T.Whitespace{}, 90, "b")
      |> expect_next_token(%T.Id{value: "bold"}, 94, ";")
      |> expect_next_token(%T.Semicolon{}, 95, "\n")
      |> expect_next_token(%T.Whitespace{}, 98, "f")
      |> expect_next_token(%T.Id{value: "font-size"}, 107, ":")
      |> expect_next_token(%T.Colon{}, 108, " ")
      |> expect_next_token(%T.Whitespace{}, 109, "1")
      |> expect_next_token(%T.Dimension{value: 14, original_value: "14", unit: "px"}, 113, ";")
      |> expect_next_token(%T.Semicolon{}, 114, "\n")
      |> expect_next_token(%T.Whitespace{}, 115, "}")
      |> expect_next_token(%T.CloseCurly{}, 116, "\n")
      |> expect_next_token(%T.Whitespace{}, 117, nil)
      |> expect_next_token(%T.EndOfFile{}, 117, nil)
    end
  end
end
